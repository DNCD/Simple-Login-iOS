//
//  MainView.swift
//  RelayEmail
//
//  Created by Thanh-Nhon Nguyen on 31/08/2021.
//

import AlertToast
import LocalAuthentication
import SimpleLoginPackage
import StoreKit
import SwiftUI

struct MainView: View {
    @EnvironmentObject private var session: Session
    @EnvironmentObject private var reachabilityObserver: ReachabilityObserver
    @EnvironmentObject private var router: AppRouter
    @Environment(\.managedObjectContext) private var managedObjectContext
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.requestReview) private var requestReview
    @StateObject private var viewModel = MainViewModel()
    @SceneStorage("SelectedTab") private var selectedItem = TabBarItem.aliases
    @State private var upgradeNeeded = false
    @State private var selectedSheet: Sheet?
    @State private var createdAlias: Alias?
    @State private var searchRequested = false
    @State private var copiedEmail: String?
    @State private var isCreatingRandomAlias = false
    @State private var routeError: Error?
    @AppStorage(kDidShowTips) private var didShowTips = false
    @AppStorage(kLaunchCount) private var launchCount = 0
    @AppStorage(kAliasCreationCount) private var aliasCreationCount = 0
    let onLogOut: () -> Void

    private enum Sheet: String, Identifiable {
        case tips = "tips"
        case createAlias = "createAlias"

        var id: String { rawValue }
    }

    var body: some View {
        let showingBiometricAuthFailureAlert = Binding<Bool>(get: {
            viewModel.biometricAuthFailed
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledBiometricAuthFailure()
            }
        })

        let showingCopiedEmailAlert = Binding<Bool>(get: {
            copiedEmail != nil
        }, set: { isShowing in
            if !isShowing {
                copiedEmail = nil
            }
        })

        TabView(selection: $selectedItem) {
            Tab(TabBarItem.aliases.title,
                systemImage: TabBarItem.aliases.systemImageName,
                value: TabBarItem.aliases) {
                AliasesView(session: session,
                            reachabilityObserver: reachabilityObserver,
                            managedObjectContext: managedObjectContext,
                            createdAlias: $createdAlias,
                            searchRequested: $searchRequested,
                            onCreateAlias: showCreateAlias,
                            onUpgrade: beginUpgradeFlow)
            }

            Tab(TabBarItem.advanced.title,
                systemImage: TabBarItem.advanced.systemImageName,
                value: TabBarItem.advanced) {
                AdvancedView()
            }

            Tab(TabBarItem.myAccount.title,
                systemImage: TabBarItem.myAccount.systemImageName,
                value: TabBarItem.myAccount) {
                AccountView(session: session,
                            upgradeNeeded: $upgradeNeeded,
                            onLogOut: onLogOut)
            }

            Tab(TabBarItem.settings.title,
                systemImage: TabBarItem.settings.systemImageName,
                value: TabBarItem.settings) {
                SettingsView()
            }
        }
        .tabViewStyle(.sidebarAdaptable)
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory {
            QuickCreateAccessory(onCreateAlias: showCreateAlias) {
                handle(.randomAlias)
            }
        }
        .onChange(of: selectedItem) {
            Vibration.selection.vibrate()
        }
        .emptyPlaceholder(isEmpty: !viewModel.canShowDetails, useZStack: true) {
            LockedView(biometryType: viewModel.biometryType,
                       onUnlock: viewModel.biometricallyAuthenticate)
                .onAppear {
                    viewModel.biometricallyAuthenticate()
                }
                .alert(isPresented: showingBiometricAuthFailureAlert) {
                    biometricAuthFailureAlert
                }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if oldPhase == .background, newPhase == .inactive {
                viewModel.requestAuthenticationIfNeeded()
            }
        }
        .onAppear {
            if !didShowTips {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    selectedSheet = .tips
                }
            }
            launchCount += 1
        }
        .onReceive(router.$pendingRoute) { route in
            handle(route)
        }
        .onChange(of: viewModel.canShowDetails) {
            handle(router.pendingRoute)
        }
        .sheet(item: $selectedSheet) { sheet in
            switch sheet {
            case .tips:
                TipsView(isFirstTime: true)
                    .onAppear {
                        didShowTips = true
                    }
            case .createAlias:
                CreateAliasView(session: session,
                                mode: nil,
                                onCreateAlias: { createdAlias in
                                    handleCreatedAlias(createdAlias)
                                },
                                onCancel: nil,
                                onOpenMyAccount: beginUpgradeFlow)
            }
        }
        .alertToastLoading(isPresenting: $isCreatingRandomAlias)
        .alertToastCopyMessage(isPresenting: showingCopiedEmailAlert, message: copiedEmail)
        .alertToastError($routeError)
    }

    private var biometricAuthFailureAlert: Alert {
        Alert(title: Text("Authentication failed"),
              message: Text("This account is protected, you must authenticate to continue."),
              primaryButton: .default(Text("Try again"), action: viewModel.biometricallyAuthenticate),
              secondaryButton: .destructive(Text("Log out"), action: onLogOut))
    }

    private func showCreateAlias() {
        Vibration.light.vibrate()
        selectedSheet = .createAlias
    }

    private func beginUpgradeFlow() {
        upgradeNeeded = true
        selectedItem = .myAccount
    }

    private func handleCreatedAlias(_ alias: Alias) {
        aliasCreationCount += 1
        // Only ask for reviews when not in macOS because macOS doesn't respect
        // the 3 time per year limit so users are prompted after every alias creations
        if launchCount >= 10, aliasCreationCount >= 5, !ProcessInfo.processInfo.isiOSAppOnMac {
            requestReview()
        }
        createdAlias = alias
        selectedItem = .aliases
    }

    /// Handles quick actions, deep links, Siri & Spotlight.
    /// Routes are kept pending while the app is locked.
    private func handle(_ route: AppRoute?) {
        guard let route, viewModel.canShowDetails else { return }
        router.consume()
        switch route {
        case .aliases:
            selectedItem = .aliases
        case .createAlias:
            selectedItem = .aliases
            selectedSheet = .createAlias
        case .randomAlias:
            selectedItem = .aliases
            createRandomAlias()
        case .search:
            selectedSheet = nil
            selectedItem = .aliases
            searchRequested = true
        case let .copy(email):
            UIPasteboard.general.string = email
            Vibration.success.vibrate()
            copiedEmail = email
        }
    }

    private func createRandomAlias() {
        guard !isCreatingRandomAlias else { return }
        Task { @MainActor in
            defer { isCreatingRandomAlias = false }
            isCreatingRandomAlias = true
            do {
                let endpoint = RandomAliasEndpoint(apiKey: session.apiKey.value,
                                                   note: nil,
                                                   mode: .word,
                                                   hostname: nil)
                let alias = try await session.execute(endpoint)
                UIPasteboard.general.string = alias.email
                Vibration.success.vibrate()
                handleCreatedAlias(alias)
                copiedEmail = alias.email
            } catch {
                routeError = error
            }
        }
    }
}

/// Shown on top of the app while local authentication is required
private struct LockedView: View {
    let biometryType: LABiometryType
    let onUnlock: () -> Void

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                LogoView(size: 88)
                Text("\(Brand.name) is locked")
                    .font(.title2.weight(.bold))
                Text("Authenticate to see your aliases")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Button(action: onUnlock) {
                    Label("Unlock", systemImage: biometryType.systemImageName)
                        .font(.headline)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.glassProminent)
                .tint(.brand)
                .padding(.top, 8)
            }
            .padding()
        }
    }
}

/// Shown above the tab bar (and inline when the tab bar is minimized)
private struct QuickCreateAccessory: View {
    let onCreateAlias: () -> Void
    let onRandomAlias: () -> Void

    var body: some View {
        ViewThatFits(in: .horizontal) {
            content(showsTitles: true)
            content(showsTitles: false)
        }
    }

    private func content(showsTitles: Bool) -> some View {
        HStack(spacing: 0) {
            Button(action: onRandomAlias) {
                label("Random alias", systemImage: "wand.and.stars", showsTitle: showsTitles)
            }

            Divider()
                .frame(height: 20)

            Button(action: onCreateAlias) {
                label("New alias", systemImage: "plus", showsTitle: showsTitles)
            }
        }
        .font(.subheadline.weight(.semibold))
        .foregroundStyle(Color.brand)
    }

    private func label(_ title: String, systemImage: String, showsTitle: Bool) -> some View {
        Group {
            if showsTitle {
                Label(title, systemImage: systemImage)
            } else {
                Image(systemName: systemImage)
                    .accessibilityLabel(Text(title))
            }
        }
        .lineLimit(1)
        .frame(maxWidth: .infinity, minHeight: 44)
        .contentShape(Rectangle())
    }
}

enum TabBarItem: String {
    case aliases = "aliases"
    case advanced = "advanced"
    case myAccount = "myAccount"
    case settings = "settings"

    var title: String {
        switch self {
        case .aliases:
            "Aliases"
        case .advanced:
            "Manage"
        case .myAccount:
            "Account"
        case .settings:
            "Settings"
        }
    }

    var systemImageName: String {
        switch self {
        case .aliases:
            "at"
        case .advanced:
            "tray.2"
        case .myAccount:
            "person.crop.circle"
        case .settings:
            "gearshape"
        }
    }
}

final class MainViewModel: ObservableObject {
    @Published private(set) var canShowDetails = false
    @Published private(set) var biometricAuthFailed = false
    @AppStorage(kBiometricAuthEnabled) private var biometricAuthEnabled = false
    @AppStorage(kUltraProtectionEnabled) private var ultraProtectionEnabled = false
    let biometryType: LABiometryType

    init() {
        let context = LAContext()
        _ = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        biometryType = context.biometryType
        canShowDetails = !biometricAuthEnabled
    }

    func handledBiometricAuthFailure() {
        biometricAuthFailed = false
    }

    func biometricallyAuthenticate() {
        let context = LAContext()
        context.localizedFallbackTitle = "Use passcode"
        context.evaluatePolicy(.deviceOwnerAuthentication,
                               localizedReason: "Unlock your aliases") { [weak self] success, _ in
            guard let self else { return }
            DispatchQueue.main.async {
                if success {
                    self.canShowDetails = true
                } else {
                    self.biometricAuthFailed = true
                }
            }
        }
    }

    func requestAuthenticationIfNeeded() {
        canShowDetails = !(biometricAuthEnabled && ultraProtectionEnabled)
    }
}
