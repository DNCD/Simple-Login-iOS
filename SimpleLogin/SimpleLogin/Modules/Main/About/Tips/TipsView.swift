//
//  TipsView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 02/02/2022.
//

import LocalAuthentication
import SimpleLoginPackage
import SwiftUI

struct TipsView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var localAuthenticator = LocalAuthenticator()
    let isFirstTime: Bool

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    if isFirstTime {
                        LogoView(size: 88)
                            .padding(.bottom, 4)
                        Text("Welcome to")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(Brand.name)
                            .font(.largeTitle.weight(.heavy))
                            .foregroundStyle(LinearGradient.brand)
                    }

                    Text("A few tips to help you get the most out of your aliases.")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                switch localAuthenticator.biometryType {
                case .touchID:
                    OnboardingTipCard(tip: .touchId)
                        .environmentObject(localAuthenticator)
                case .faceID:
                    OnboardingTipCard(tip: .faceId)
                        .environmentObject(localAuthenticator)
                default:
                    EmptyView()
                }
                OnboardingTipCard(tip: .contextMenu)
                OnboardingTipCard(tip: .fullScreen)
                OnboardingTipCard(tip: .siriShortcuts)
                OnboardingTipCard(tip: .shareExtension)
                OnboardingTipCard(tip: .keyboardExtension)

                if isFirstTime {
                    PrimaryButton(title: "Get started") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .padding(.top, 20)
            .padding()
            .frame(maxWidth: 640)
            .frame(maxWidth: .infinity)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarHidden(isFirstTime)
        .navigationTitle("Tips")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading: isFirstTime ? closeButton : nil)
        .alertToastMessage($localAuthenticator.message)
        .alertToastError($localAuthenticator.error)
    }

    private var closeButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Close")
        })
    }
}

struct TipsView_Previews: PreviewProvider {
    static var previews: some View {
        TipsView(isFirstTime: true)
    }
}

private struct OnboardingTipCard: View {
    @EnvironmentObject var localAuthenticator: LocalAuthenticator
    @State private var showingSheet = false
    let tip: OnboardingTip

    var body: some View {
        VStack {
            HStack {
                switch tip {
                case .touchId:
                    Toggle(isOn: $localAuthenticator.biometricAuthEnabled) {
                        Text(LABiometryType.touchID.description)
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .brand))

                case .faceId:
                    Toggle(isOn: $localAuthenticator.biometricAuthEnabled) {
                        Text(LABiometryType.faceID.description)
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .brand))

                default:
                    Text(tip.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                }
            }

            HStack {
                Text(tip.description)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                Image(systemName: tip.systemIconName)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.brand)
                    .frame(width: 40)
            }

            if let action = tip.action {
                Button(action: {
                    handleAction()
                }, label: {
                    Text(action)
                        .font(.headline)
                })
            }

            if tip == .contextMenu {
                AliasCompactView(alias: .sample,
                                 onCopy: {},
                                 onSendMail: {},
                                 onToggle: {},
                                 onPin: {},
                                 onUnpin: {},
                                 onDelete: {})
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .sheet(isPresented: $showingSheet) {
            switch tip {
            case .fullScreen:
                AliasEmailView(email: "a-long-and-complicated-alias@my-domain.com")
            case .shareExtension:
                if let url = URL(string: "https://www.wikipedia.org/") {
                    ShareSheetView(activityItems: [url])
                } else {
                    EmptyView()
                }
            default:
                EmptyView()
            }
        }
    }

    private func handleAction() {
        switch tip {
        case .contextMenu, .faceId, .touchId, .siriShortcuts:
            break
        case .fullScreen, .shareExtension:
            showingSheet = true
        case .keyboardExtension:
            UIApplication.shared.openSettings()
        }
    }
}

extension Alias {
    static var sample: Alias {
        .init(id: 0,
              email: "my.alias@example.com",
              name: nil,
              enabled: true,
              creationTimestamp: Date().timeIntervalSince1970,
              blockCount: 15,
              forwardCount: 25,
              replyCount: 35,
              note: nil,
              pgpSupported: false,
              pgpDisabled: false,
              mailboxes: [.johnDoe],
              latestActivity: nil,
              pinned: true)
    }
}
