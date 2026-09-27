//
//  AliasContactsView.swift
//  RelayEmail
//
//  Created by Thanh-Nhon Nguyen on 20/11/2021.
//

import Combine
import SimpleLoginPackage
import SwiftUI

struct AliasContactsView: View {
    @StateObject private var viewModel: AliasContactsViewModel
    @State private var copiedText: String?
    @State private var newContactEmail = ""
    @State private var selectedUrlString: String?
    private let onUpgrade: () -> Void

    init(alias: Alias, session: Session, onUpgrade: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: .init(alias: alias, session: session))
        self.onUpgrade = onUpgrade
    }

    var body: some View {
        let showingCopyAlert = makeShowingCopyAlertBinding()
        let showingCreatedContactAlert = makeShowingCreatedContactAlert()
        List {
            Section(header: Text("Create new contact"),
                    footer: createContactSectionFooter) {
                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .font(.title2)
                        .foregroundStyle(Color.brand)
                    TextField("name@example.com", text: $newContactEmail)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .submitLabel(.done)
                        .onSubmit {
                            guard !newContactEmail.isEmpty else { return }
                            viewModel.createContact(contactEmail: newContactEmail)
                        }
                    Button("Add") {
                        viewModel.createContact(contactEmail: newContactEmail)
                    }
                    .buttonStyle(.glassProminent)
                    .tint(.brand)
                    .disabled(newContactEmail.isEmpty)
                }
            }

            Section(content: {
                if !viewModel.contacts.isEmpty {
                    ForEach(viewModel.contacts, id: \.id) { contact in
                        ContactView(viewModel: viewModel,
                                    copiedText: $copiedText,
                                    contact: contact)
                            .onAppear {
                                viewModel.getMoreContactsIfNeed(currentContact: contact)
                            }
                    }
                } else if !viewModel.isFetchingContacts {
                    ContentUnavailableView("No contacts yet",
                                           systemImage: "person.2",
                                           description: Text("Add a contact to send emails from this alias."))
                        .listRowBackground(Color.clear)
                }

                if viewModel.isFetchingContacts {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }, header: {
                if !viewModel.contacts.isEmpty {
                    Text("Contacts")
                }
            })
        }
        .listStyle(.insetGrouped)
        .refreshable { await viewModel.refresh() }
        .animation(.default, value: viewModel.contacts.count)
        .toolbar {
            ToolbarItem(placement: .principal) {
                AliasNavigationTitleView(alias: viewModel.alias)
            }
        }
        .onAppear {
            viewModel.getMoreContactsIfNeed(currentContact: nil)
        }
        .onReceive(Just(viewModel.createdContact)) { createdContact in
            if createdContact != nil {
                newContactEmail = ""
            }
        }
        .alert("Please upgrade to create contacts",
               isPresented: $viewModel.shouldUpgrade,
               actions: {
                   Button("Upgrade", role: nil, action: onUpgrade)
                   Button("Cancel", role: .cancel) {}
               })
        .betterSafariView(urlString: $selectedUrlString)
        .alertToastCopyMessage(isPresenting: showingCopyAlert, message: copiedText)
        .alertToastError($viewModel.error)
        .alertToastLoading(isPresenting: $viewModel.isLoading)
        .alertToastMessage(showingCreatedContactAlert)
    }

    private func makeShowingCopyAlertBinding() -> Binding<Bool> {
        .init(get: {
            copiedText != nil
        }, set: { isShowing in
            if !isShowing {
                copiedText = nil
            }
        })
    }

    private func makeShowingCreatedContactAlert() -> Binding<String?> {
        .init(get: {
            if viewModel.createdContact != nil {
                "Created new contact"
            } else {
                nil
            }
        }, set: { message in
            if message == nil {
                viewModel.handledCreatedContact()
            }
        })
    }

    private var createContactSectionFooter: some View {
        Button("How to send emails from your alias?") {
            selectedUrlString = Brand.sendEmailDocsUrlString
        }
        .foregroundColor(.brand)
    }
}

private struct ContactView: View {
    @ObservedObject var viewModel: AliasContactsViewModel
    @Binding var copiedText: String?
    let contact: Contact

    var body: some View {
        Menu(content: {
            Section {
                Button(action: {
                    Vibration.soft.vibrate()
                    copiedText = contact.reverseAlias
                    UIPasteboard.general.string = contact.reverseAlias
                }, label: {
                    Label("Copy reverse-alias\n(with display name)", systemImage: "doc.on.doc")
                })

                Button(action: {
                    Vibration.soft.vibrate()
                    copiedText = contact.reverseAliasAddress
                    UIPasteboard.general.string = contact.reverseAliasAddress
                }, label: {
                    Label("Copy reverse-alias\n(without display name)", systemImage: "doc.on.doc")
                })
            }

            Section {
                Button(action: {
                    if let mailToUrl = URL(string: "mailto:\(contact.reverseAliasAddress)") {
                        UIApplication.shared.open(mailToUrl)
                    }
                }, label: {
                    Label("Send email", systemImage: "paperplane")
                })
            }

            Section {
                if contact.blockForward {
                    Button(action: {
                        viewModel.toggleContact(contact)
                    }, label: {
                        Label("Unblock", systemImage: "hand.thumbsup")
                    })
                } else {
                    Button(action: {
                        viewModel.toggleContact(contact)
                    }, label: {
                        Label("Block", systemImage: "hand.raised")
                    })
                }
            }

            Section {
                DeleteMenuButton {
                    viewModel.deleteContact(contact)
                }
            }
        }, label: {
            HStack(spacing: 12) {
                AliasAvatar(email: contact.email, isEnabled: !contact.blockForward, size: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(contact.email)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(contact.blockForward ? Color.secondary : Color.primary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Text("Added \(contact.relativeCreationDateString)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if contact.blockForward {
                    Label("Blocked", systemImage: "nosign")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.12), in: Capsule())
                }
            }
            .contentShape(Rectangle())
        })
    }
}
