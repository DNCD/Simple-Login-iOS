//
//  ApiKeyView.swift
//  RelayEmail
//
//  Created by Thanh-Nhon Nguyen on 03/08/2021.
//

import Combine
import SimpleLoginPackage
import SwiftUI

struct ApiKeyView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel: ApiKeyViewModel
    @State private var showingLoadingAlert = false
    @State private var value = ""
    @State private var showingKey = false
    @State private var selectedUrlString: String?
    let onSetApiKey: (ApiKey) -> Void

    init(apiService: APIServiceProtocol, onSetApiKey: @escaping (ApiKey) -> Void) {
        _viewModel = StateObject(wrappedValue: .init(apiService: apiService))
        self.onSetApiKey = onSetApiKey
    }

    var body: some View {
        NavigationView {
            Form {
                Section(content: {
                    HStack {
                        Group {
                            if showingKey {
                                TextField("Paste your API key", text: $value)
                            } else {
                                SecureField("Paste your API key", text: $value)
                            }
                        }
                        .textContentType(.password)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .font(.body.monospaced())
                        .submitLabel(.go)
                        .onSubmit(submit)

                        Button(action: {
                            showingKey.toggle()
                        }, label: {
                            Image(systemName: showingKey ? "eye.slash" : "eye")
                                .foregroundStyle(.secondary)
                        })
                        .buttonStyle(.plain)
                        .accessibilityLabel(Text(showingKey ? "Hide API key" : "Show API key"))
                    }

                    PasteButton(payloadType: String.self) { strings in
                        if let pasted = strings.first {
                            value = pasted.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    }
                    .labelStyle(.titleAndIcon)
                    .buttonBorderShape(.capsule)
                }, header: {
                    Text("API key")
                }, footer: {
                    footerText
                })

                Section {
                    Button(action: submit) {
                        Text("Log in")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                    .disabled(value.isEmpty)
                }

                Section(content: {
                    Button(action: {
                        selectedUrlString = apiKeyPageUrlString
                    }, label: {
                        Label("Get an API key", systemImage: "key.viewfinder")
                    })
                }, footer: {
                    Text("Create an API key from your \(Brand.name) dashboard, then paste it here.")
                })
            }
            .navigationBarTitle("Log in with API key", displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Text("Close")
            }))
            .betterSafariView(urlString: $selectedUrlString)
        }
        .accentColor(.brand)
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .onReceive(Just(viewModel.apiKey)) { apiKey in
            if let apiKey {
                onSetApiKey(apiKey)
            }
        }
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastError($viewModel.error)
    }

    private var apiKeyPageUrlString: String {
        let apiUrl = Preferences.shared.apiUrl
        guard let url = URL(string: apiUrl) else { return Brand.apiKeyUrlString }
        return url.appendingPathComponent("dashboard/api_key").absoluteString
    }

    private func submit() {
        let trimmedValue = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty else { return }
        viewModel.checkApiKey(apiKey: ApiKey(value: trimmedValue))
    }

    private var footerText: some View {
        // swiftlint:disable:next line_length
        Label("API keys should be kept secret and treated like passwords, they can be used to gain access to your account.",
              systemImage: "exclamationmark.shield.fill")
            .foregroundStyle(.orange)
    }
}
