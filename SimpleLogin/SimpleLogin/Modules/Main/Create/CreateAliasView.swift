//
//  CreateAliasView.swift
//  RelayEmail
//
//  Created by Thanh-Nhon Nguyen on 14/09/2021.
//

import Combine
import SimpleLoginPackage
import SwiftUI

struct CreateAliasView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel: CreateAliasViewModel
    @State private var showingLoadingAlert = false

    private let onCreateAlias: (Alias) -> Void
    private let onCancel: (() -> Void)?
    private let onOpenMyAccount: (() -> Void)?

    enum Mode {
        case text(String)
        case url(URL)
    }

    init(session: Session,
         mode: Mode?,
         onCreateAlias: @escaping (Alias) -> Void,
         onCancel: (() -> Void)?,
         onOpenMyAccount: (() -> Void)?) {
        _viewModel = StateObject(wrappedValue: .init(session: session,
                                                     mode: mode))
        self.onCreateAlias = onCreateAlias
        self.onCancel = onCancel
        self.onOpenMyAccount = onOpenMyAccount
    }

    var body: some View {
        NavigationView {
            Group {
                if let options = viewModel.options {
                    ContentView(viewModel: viewModel,
                                options: options,
                                mailboxes: viewModel.mailboxes)
                } else if !viewModel.isLoading {
                    Button(action: viewModel.fetchOptionsAndMailboxes) {
                        Label("Retry", systemImage: "gobackward")
                    }
                }
            }
            .navigationBarTitle("Create an alias", displayMode: .inline)
            .navigationBarItems(leading: cancelButton)
        }
        .accentColor(.brand)
        .emptyPlaceholder(isEmpty: viewModel.options?.canCreate == false) {
            UpgradeNeededView(onOk: onCancel) {
                onOpenMyAccount?()
                presentationMode.wrappedValue.dismiss()
            }
        }
        .onAppear {
            if viewModel.options == nil || viewModel.mailboxes.isEmpty {
                viewModel.fetchOptionsAndMailboxes()
            }
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .onReceive(Just(viewModel.createdAlias)) { createdAlias in
            if let createdAlias {
                // Workaround of a strange bug: https://developer.apple.com/forums/thread/675216
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    onCreateAlias(createdAlias)
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastError($viewModel.error)
    }

    private var cancelButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
            onCancel?()
        }, label: {
            Text("Cancel")
        })
    }
}

private struct ContentView: View {
    @ObservedObject var viewModel: CreateAliasViewModel
    @State private var isInitialized = false
    @State private var selectedUrlString: String?
    let options: AliasOptions
    let mailboxes: [Mailbox]

    var body: some View {
        Form {
            prefixAndSuffixSection
            notesSection
            mailboxesSection
            randomSection
        }
        .safeAreaInset(edge: .bottom) {
            PrimaryButton(title: "Create alias", action: viewModel.createAlias)
                .disabled(!viewModel.canCreate)
                .opacity(viewModel.canCreate ? 1 : 0.5)
                .padding(.horizontal)
                .padding(.bottom, 8)
        }
    }

    private var prefixAndSuffixSection: some View {
        Section(content: {
            VStack(alignment: .leading) {
                HStack {
                    TextField("Custom prefix", text: $viewModel.prefix.animation())
                        .labelsHidden()
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .foregroundColor(viewModel.prefix.isValidPrefix ? .primary : .red)

                    if !viewModel.prefix.isEmpty {
                        Button(action: {
                            viewModel.prefix = ""
                        }, label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.tertiary)
                        })
                        .buttonStyle(.borderless)
                        .accessibilityLabel(Text("Clear prefix"))
                    }
                }

                if !viewModel.prefix.isEmpty, !viewModel.prefix.isValidPrefix {
                    Text("Only lowercase letters, numbers, dot (.), dashes (-) & underscore are supported.")
                        .font(.caption)
                        .foregroundColor(.red)
                        .animation(.default, value: viewModel.prefix)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if viewModel.canSuggestPrefixes {
                prefixSuggestionsView
            }

            if let selectedSuffix = viewModel.selectedSuffix {
                NavigationLink(destination: {
                    EditSuffixView(selectedSuffix: $viewModel.selectedSuffix, suffixes: options.suffixes)
                }, label: {
                    VStack(alignment: .leading) {
                        Text(selectedSuffix.value)
                        Text(selectedSuffix.domainType.localizedDescription)
                            .font(.caption)
                            .foregroundColor(selectedSuffix.domainType.color)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                })
            }

            if viewModel.prefix.isValidPrefix {
                VStack(alignment: .leading) {
                    Text("You're about to create".uppercased())
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    Text(viewModel.prefix + (viewModel.selectedSuffix?.value ?? ""))
                        .fontWeight(.medium)
                        .transaction { transaction in
                            transaction.animation = nil
                        }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
            }
        }, header: {
            Text("Alias address")
        })
    }

    private var prefixSuggestionsView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: viewModel.suggestPrefixes) {
                if viewModel.isSuggestingPrefixes {
                    Label("Thinking…", systemImage: "sparkles")
                        .symbolEffect(.pulse)
                } else {
                    Label("Suggest with Apple Intelligence", systemImage: "sparkles")
                }
            }
            .buttonStyle(.borderless)
            .disabled(viewModel.isSuggestingPrefixes)

            if !viewModel.prefixSuggestions.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(viewModel.prefixSuggestions, id: \.self) { suggestion in
                            Button(suggestion) {
                                viewModel.prefix = suggestion
                            }
                            .buttonStyle(.glass)
                            .controlSize(.small)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
        }
    }

    private var notesSection: some View {
        Section(content: {
            TextField("Where will you use this alias?", text: $viewModel.notes, axis: .vertical)
                .lineLimit(2...6)
        }, header: {
            Text("Notes")
        })
    }

    private var randomSection: some View {
        Section(content: {
            Button(action: {
                viewModel.random(mode: .word)
            }, label: {
                Label("Random words", systemImage: "textformat.abc")
                    .labelStyle(.tile(.purple))
                    .foregroundStyle(Color(.label))
            })

            Button(action: {
                viewModel.random(mode: .uuid)
            }, label: {
                Label("Random characters", systemImage: "number")
                    .labelStyle(.tile(.teal))
                    .foregroundStyle(Color(.label))
            })
        }, header: {
            Text("Or create a random alias")
        }, footer: {
            Text("Random aliases are created instantly with your default mailbox.")
        })
    }

    private var mailboxesSection: some View {
        Section(content: {
            NavigationLink(destination: {
                EditMailboxesView(mailboxIds: $viewModel.mailboxIds, mailboxes: viewModel.mailboxes)
            }, label: {
                let selectedMailboxes = viewModel.mailboxes.filter { viewModel.mailboxIds.contains($0.id) }
                Text(selectedMailboxes.map(\.email).joined(separator: "\n"))
            })
        }, header: {
            Text("Mailboxes")
        }, footer: {
            Button("What are mailboxes?") {
                selectedUrlString = Brand.addMailboxDocsUrlString
            }
            .font(.footnote)
            .foregroundColor(.brand)
        })
        .transaction { transaction in
            transaction.animation = nil
        }
        .betterSafariView(urlString: $selectedUrlString)
    }
}

private struct EditMailboxesView: View {
    @Binding var mailboxIds: [Int]
    let mailboxes: [Mailbox]

    var body: some View {
        Form {
            Section {
                ForEach(mailboxes, id: \.id) { mailbox in
                    HStack {
                        Text(mailbox.email)
                            .foregroundColor(mailbox.verified ? .primary : .secondary)
                        Spacer()
                        if mailboxIds.contains(mailbox.id) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.accentColor)
                        }
                        if !mailbox.verified {
                            BorderedText.unverified
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard mailbox.verified else { return }
                        if mailboxIds.contains(mailbox.id), mailboxIds.count > 1 {
                            mailboxIds.removeAll { $0 == mailbox.id }
                        } else if !mailboxIds.contains(mailbox.id) {
                            mailboxIds.append(mailbox.id)
                        }
                    }
                }
            }
        }
        .navigationTitle("Mailboxes")
        .navigationBarItems(trailing: reloadButton)
    }

    private var reloadButton: some View {
        Button(action: {
            if let defaultMailbox = mailboxes.first(where: { $0.default }) {
                mailboxIds = [defaultMailbox.id]
            }
        }, label: {
            Image(systemName: "gobackward")
        })
        .padding()
    }
}

struct EditSuffixView: View {
    @Environment(\.presentationMode) private var presentationMode
    @Binding var selectedSuffix: Suffix?
    let suffixes: [Suffix]

    var body: some View {
        Form {
            ForEach(suffixes, id: \.value) { suffix in
                HStack {
                    VStack(alignment: .leading) {
                        Text(suffix.value)
                        Text(suffix.domainType.localizedDescription)
                            .font(.caption)
                            .foregroundColor(suffix.domainType.color)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                    Spacer()

                    if suffix.value == selectedSuffix?.value {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedSuffix = suffix
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}
