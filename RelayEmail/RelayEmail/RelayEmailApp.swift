//
//  RelayEmailApp.swift
//  RelayEmail
//
//  Created by Thanh-Nhon Nguyen on 28/06/2021.
//

import Combine
import CoreData
import CoreSpotlight
import SimpleLoginPackage
import SwiftUI
import TipKit

@main
struct RelayEmailApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @AppStorage(kBiometricAuthEnabled) var biometricAuthEnabled = false
    @AppStorage(kUltraProtectionEnabled) var ultraProtectionEnabled = false
    @AppStorage(kAppearance) private var appearance: AppearanceMode = .system
    @AppStorage(kAliasDisplayMode) private var displayMode: AliasDisplayMode = .default
    @AppStorage(kDidShowTips) private var didShowTips = false
    @State private var preferences = Preferences.shared
    @State private var apiKey: ApiKey?
    @State private var apiService: APIServiceProtocol?
    @StateObject private var router = AppRouter.shared
    private let reachabilityObserver = ReachabilityObserver()
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "RelayEmail")
        container.loadPersistentStores { _, error in
            if let error {
                print("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()

    init() {
        AppearanceMode.migrateLegacySettingIfNeeded()
        try? Tips.configure([.displayFrequency(.immediate)])
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let apiKey, let apiService {
                    MainView {
                        try? KeychainService.shared.setApiKey(nil)
                        try? DataController(context: persistentContainer.viewContext).reset()
                        SpotlightIndexer.removeAll()
                        self.apiKey = nil
                        self.apiService = nil
                        biometricAuthEnabled = false
                        ultraProtectionEnabled = false
                        appearance = .system
                        displayMode = .default
                        didShowTips = false
                        if let cookies = HTTPCookieStorage.shared.cookies {
                            for cookie in cookies {
                                HTTPCookieStorage.shared.deleteCookie(cookie)
                            }
                        }
                    }
                    .environment(\.managedObjectContext, persistentContainer.viewContext)
                    .environmentObject(preferences)
                    .environmentObject(Session(apiKey: apiKey, apiService: apiService))
                    .environmentObject(reachabilityObserver)
                    .environmentObject(router)
                    .sensitiveContent {
                        ZStack {
                            Color(.systemBackground)
                            LogoView(size: 96)
                        }
                        .ignoresSafeArea()
                    }
                } else {
                    LogInView(apiUrl: preferences.apiUrl) { apiKey, apiService in
                        try? KeychainService.shared.setApiKey(apiKey)
                        self.apiKey = apiKey
                        self.apiService = apiService
                    }
                    .environmentObject(preferences)
                }
            }
            .tint(.brand)
            .accentColor(.brand)
            .onAppear {
                appearance.apply()
                router.consumePendingQuickAction()
            }
            .onReceive(NotificationCenter.default.publisher(for: .pendingQuickAction)) { _ in
                router.consumePendingQuickAction()
            }
            .onOpenURL { url in
                router.handle(url: url)
            }
            .onContinueUserActivity(CSSearchableItemActionType) { userActivity in
                router.handle(spotlightActivity: userActivity)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            appearance.apply()
            if newPhase == .active {
                router.consumePendingQuickAction()
            }
        }
        .onChange(of: appearance) { _, newValue in
            newValue.apply()
        }
    }
}
