//
//  LogInView.swift
//  RelayEmail
//
//  Created by Thanh-Nhon Nguyen on 29/07/2021.
//

import Combine
import SimpleLoginPackage
import SwiftUI

struct LogInView: View {
    @EnvironmentObject private var preferences: Preferences
    @StateObject private var viewModel: LogInViewModel

    @State private var showingAboutView = false
    @State private var showingApiKeyView = false
    @State private var showingApiUrlView = false
    @State private var showingResetPasswordAlert = false
    @State private var showingResetEmailSentAlert = false

    @State private var launching = true
    @State private var showingSignUpView = false

    @State private var otpMode: OtpMode?

    @State private var showingLoadingAlert = false

    let onComplete: (ApiKey, APIServiceProtocol) -> Void

    init(apiUrl: String,
         onComplete: @escaping (ApiKey, APIServiceProtocol) -> Void) {
        _viewModel = StateObject(wrappedValue: .init(apiUrl: apiUrl))
        self.onComplete = onComplete
    }

    var body: some View {
        let showingOtpViewSheet = Binding<Bool>(get: {
            otpMode != nil && UIDevice.current.userInterfaceIdiom != .phone
        }, set: { isShowing in
            if !isShowing {
                otpMode = nil
            }
        })

        let showingOtpViewFullScreen = Binding<Bool>(get: {
            otpMode != nil && UIDevice.current.userInterfaceIdiom == .phone
        }, set: { isShowing in
            if !isShowing {
                otpMode = nil
            }
        })

        let showingResetEmailSentAlert = Binding<Bool>(get: {
            viewModel.resetEmail != nil
        }, set: { isShowing in
            if !isShowing {
                viewModel.handledResetEmail()
            }
        })

        ZStack(alignment: .top) {
            backgroundView

            if launching {
                VStack {
                    Spacer()
                    LogoWithNameView()
                    ProgressView()
                        .padding(.top)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        LogoWithNameView(size: viewModel.isShowingKeyboard ? 64 : 88)
                            .padding(.top, 24)

                        if !viewModel.isShowingKeyboard {
                            Text("Protect your inbox with email aliases")
                                .font(.callout)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        VStack(spacing: 16) {
                            EmailPasswordView(email: $viewModel.email,
                                              password: $viewModel.password,
                                              mode: .logIn,
                                              onAction: viewModel.logIn)

                            Button(action: {
                                showingResetPasswordAlert = true
                            }, label: {
                                Text("Forgot password?")
                                    .font(.subheadline.weight(.medium))
                            })

                            dividerView

                            SecondaryButton(title: "Log in with API key") {
                                showingApiKeyView = true
                            }

                            if featureFlags.protonLoginEnabled {
                                LogInWithProtonButtonView(onSuccess: { apiKey in
                                    onComplete(apiKey, viewModel.apiService)
                                }, onError: { error in
                                    viewModel.error = error
                                })
                            }
                        }
                        .frame(maxWidth: 480)
                        .sheet(isPresented: showingOtpViewSheet) { otpView() }
                        .fullScreenCover(isPresented: showingOtpViewFullScreen) { otpView() }

                        bottomView
                            .fullScreenCover(isPresented: $showingSignUpView) {
                                SignUpView(apiService: viewModel.apiService) { email, password in
                                    Task {
                                        viewModel.email = email
                                        viewModel.password = password
                                        await viewModel.logIn()
                                    }
                                }
                            }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                    .frame(maxWidth: .infinity)
                }
                .scrollDismissesKeyboard(.interactively)
                .safeAreaInset(edge: .top) { topView }
            }
        }
        .animation(.default, value: viewModel.isShowingKeyboard)
        .animation(.default, value: launching)
        .onReceive(Just(preferences.apiUrl)) { apiUrl in
            viewModel.updateApiUrl(apiUrl)
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .onReceive(Just(viewModel.userLogin)) { userLogin in
            guard let userLogin else { return }
            if userLogin.isMfaEnabled {
                otpMode = .logIn(mfaKey: userLogin.mfaKey ?? "")
            } else if let apiKey = userLogin.apiKey {
                onComplete(.init(value: apiKey), viewModel.apiService)
            }
            viewModel.handledUserLogin()
        }
        .onReceive(Just(viewModel.shouldActivate)) { shouldActivate in
            if shouldActivate {
                otpMode = .activate(email: viewModel.email)
                viewModel.handledShouldActivate()
            }
        }
        .onAppear {
            if let apiKey = KeychainService.shared.getApiKey() {
                onComplete(apiKey, viewModel.apiService)
            } else {
                launching = false
            }
        }
        .alert(isPresented: showingResetEmailSentAlert) {
            Alert(title: Text("We've sent you an email"),
                  // swiftlint:disable:next line_length
                  message: Text("Please check the inbox of your email \(viewModel.resetEmail ?? "") and follow the instructions."),
                  dismissButton: .default(Text("OK")))
        }
        .textFieldAlert(isPresented: $showingResetPasswordAlert, config: resetPasswordConfig)
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastError($viewModel.error)
    }

    private var backgroundView: some View {
        ZStack {
            Color(.systemGroupedBackground)
            LinearGradient.brand
                .opacity(0.25)
                .frame(height: 360)
                .blur(radius: 80)
                .offset(y: -160)
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .ignoresSafeArea()
    }

    private var topView: some View {
        HStack {
            Color.clear
                .frame(width: 0, height: 0)
                .sheet(isPresented: $showingAboutView) {
                    NavigationView {
                        AboutView()
                    }
                }

            Color.clear
                .frame(width: 0, height: 0)
                .sheet(isPresented: $showingApiKeyView) {
                    ApiKeyView(apiService: viewModel.apiService) { apiKey in
                        onComplete(apiKey, viewModel.apiService)
                    }
                }

            Color.clear
                .frame(width: 0, height: 0)
                .sheet(isPresented: $showingApiUrlView) {
                    ApiUrlView(apiUrl: preferences.apiUrl)
                }

            Spacer()

            Menu(content: {
                Section {
                    Button(action: {
                        showingApiKeyView = true
                    }, label: {
                        Label("Log in using API key", systemImage: "key")
                    })

                    Button(action: {
                        showingApiUrlView = true
                    }, label: {
                        Label("Edit API URL", systemImage: "link")
                    })
                }

                Section {
                    Button(action: {
                        showingAboutView = true
                    }, label: {
                        Label("About \(Brand.name)", systemImage: "info.circle")
                    })
                }
            }, label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title2)
                    .accessibilityLabel(Text("More options"))
            })
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private var dividerView: some View {
        HStack(spacing: 12) {
            horizontalLine
            Text("OR")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
            horizontalLine
        }
        .padding(.vertical, 4)
    }

    private var bottomView: some View {
        HStack(spacing: 4) {
            Text("New to \(Brand.name)?")
                .foregroundStyle(.secondary)
            Button(action: {
                showingSignUpView.toggle()
            }, label: {
                Text("Create an account")
                    .fontWeight(.semibold)
            })
        }
        .font(.subheadline)
        .padding(.top, 8)
    }

    private var horizontalLine: some View {
        Color.secondary
            .opacity(0.3)
            .frame(height: 1)
    }

    private func otpView() -> some View {
        OtpView(mode: $otpMode,
                apiService: viewModel.apiService,
                onVerification: { apiKey in
                    onComplete(apiKey, viewModel.apiService)
                },
                onActivation: viewModel.logIn)
    }

    private var resetPasswordConfig: TextFieldAlertConfig {
        TextFieldAlertConfig(title: "Reset forgotten password",
                             message: "Enter your email address",
                             placeholder: "Ex: john.doe@example.com",
                             keyboardType: .emailAddress,
                             autocapitalizationType: .none,
                             clearButtonMode: .whileEditing,
                             actionTitle: "Submit",
                             action: viewModel.resetPassword(email:))
    }
}
