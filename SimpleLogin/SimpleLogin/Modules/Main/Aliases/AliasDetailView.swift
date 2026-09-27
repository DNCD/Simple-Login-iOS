//
//  AliasDetailView.swift
//  RelayEmail
//
//  Created by Thanh-Nhon Nguyen on 04/11/2021.
//

import Combine
import SimpleLoginPackage
import SwiftUI

/// A view that takes an alias as binding to properly show the alias details
/// or a placeholder view when the binding is nil.
/// To achieve the "dismiss" feeling when the alias is deleted in iPad.
struct AliasDetailWrapperView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedAlias: Alias?
    private let session: Session
    let onUpdateAlias: (Alias) -> Void
    let onDeleteAlias: (Alias) -> Void
    let onUpgrade: () -> Void

    init(selectedAlias: Binding<Alias?>,
         session: Session,
         onUpdateAlias: @escaping (Alias) -> Void,
         onDeleteAlias: @escaping (Alias) -> Void,
         onUpgrade: @escaping () -> Void) {
        _selectedAlias = selectedAlias
        self.session = session
        self.onUpdateAlias = onUpdateAlias
        self.onDeleteAlias = onDeleteAlias
        self.onUpgrade = onUpgrade
    }

    var body: some View {
        if let selectedAlias {
            AliasDetailView(alias: selectedAlias,
                            session: session,
                            onUpdateAlias: onUpdateAlias,
                            onDeleteAlias: { deletedAlias in
                                onDeleteAlias(deletedAlias)
                                // Dismiss when in single view mode (iPhone)
                                dismiss()
                                // Show placeholder view in master detail mode (iPad)
                                self.selectedAlias = nil
                            },
                            onUpgrade: onUpgrade)
        } else {
            DetailPlaceholderView.aliasDetails
        }
    }
}

struct AliasDetailView: View {
    @StateObject private var viewModel: AliasDetailViewModel
    @State private var showingLoadingAlert = false
    @State private var showingDeletionAlert = false
    @State private var showingAliasEmailSheet = false
    @State private var showingAliasFullScreen = false
    @State private var copiedText: String?
    let onUpgrade: () -> Void

    init(alias: Alias,
         session: Session,
         onUpdateAlias: @escaping (Alias) -> Void,
         onDeleteAlias: @escaping (Alias) -> Void,
         onUpgrade: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: .init(alias: alias,
                                                     session: session,
                                                     onUpdateAlias: onUpdateAlias,
                                                     onDeleteAlias: onDeleteAlias))
        self.onUpgrade = onUpgrade
    }

    var body: some View {
        List {
            ActionsSection(viewModel: viewModel,
                           copiedText: $copiedText,
                           enterFullScreen: showAliasInFullScreen,
                           onUpgrade: onUpgrade)
            NotesSection(viewModel: viewModel)
            MailboxesSection(viewModel: viewModel)
            NameSection(viewModel: viewModel)
            ActivitiesSection(viewModel: viewModel, copiedText: $copiedText)
            Section {
                Button(role: .destructive, action: confirmDeletion) {
                    Label("Delete alias", systemImage: "trash")
                        .foregroundStyle(.red)
                }
            }
        }
        .listStyle(.insetGrouped)
        .listSectionSpacing(.compact)
        .refreshable { await viewModel.refresh() }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu(content: {
                    ShareLink(item: viewModel.alias.email) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }

                    Button(action: showAliasInFullScreen) {
                        Label.enterFullScreen
                    }

                    Section {
                        Button(role: .destructive, action: confirmDeletion) {
                            Label.delete
                        }
                    }
                }, label: {
                    Label("More", systemImage: "ellipsis")
                })
            }
        }
        .disabled(viewModel.isUpdating)
        .onReceive(Just(viewModel.isUpdating)) { isUpdating in
            showingLoadingAlert = isUpdating
        }
        .fullScreenCover(isPresented: $showingAliasFullScreen) {
            AliasEmailView(email: viewModel.alias.email)
        }
        .sheet(isPresented: $showingAliasEmailSheet) {
            AliasEmailView(email: viewModel.alias.email)
        }
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastCopyMessage($copiedText)
        .alertToastError($viewModel.error)
        .alert(isPresented: $showingDeletionAlert) {
            Alert.deleteConfirmation(alias: viewModel.alias) {
                viewModel.delete()
            }
        }
    }

    private func confirmDeletion() {
        Vibration.warning.vibrate(fallBackToOldSchool: true)
        showingDeletionAlert = true
    }

    private func showAliasInFullScreen() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            showingAliasEmailSheet = true
        } else {
            showingAliasFullScreen = true
        }
    }
}

// MARK: - Sections

private struct ActionsSection: View {
    @State private var showingContacts = false
    @ObservedObject var viewModel: AliasDetailViewModel
    @Binding var copiedText: String?
    var enterFullScreen: () -> Void
    let onUpgrade: () -> Void

    private var alias: Alias {
        viewModel.alias
    }

    var body: some View {
        Section(content: {
            LabeledContent(content: {
                Text(alias.relativeCreationDateString)
            }, label: {
                Label("Created", systemImage: "calendar")
                    .labelStyle(.tile(.gray))
            })

            Button(action: enterFullScreen) {
                Label("Show in full screen", systemImage: "arrow.up.left.and.arrow.down.right")
                    .labelStyle(.tile(.brand))
                    .foregroundStyle(Color(.label))
            }
        }, header: {
            header
                .textCase(nil)
                .padding(.bottom, 12)
        })
    }

    private var header: some View {
        VStack(spacing: 14) {
            AliasAvatar(email: alias.email, isEnabled: alias.enabled, size: 72)

            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    if alias.pinned {
                        Image(systemName: "pin.fill")
                            .foregroundStyle(.orange)
                    }
                    Text(alias.email)
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .textSelection(.enabled)
                }

                Label(alias.enabled ? "Forwarding emails" : "Blocking all emails",
                      systemImage: alias.enabled ? "checkmark.circle.fill" : "pause.circle.fill")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(alias.enabled ? Color.green : Color.secondary)
            }

            GlassEffectContainer(spacing: 16) {
                HStack(spacing: 16) {
                    actionButton(title: "Copy", systemImage: "doc.on.doc.fill") {
                        Vibration.soft.vibrate()
                        copiedText = alias.email
                        UIPasteboard.general.string = alias.email
                    }

                    NavigationLink(isActive: $showingContacts,
                                   destination: {
                                       AliasContactsView(alias: alias,
                                                         session: viewModel.session,
                                                         onUpgrade: onUpgrade)
                                   },
                                   label: {
                                       actionButton(title: "Contacts", systemImage: "paperplane.fill") {
                                           showingContacts = true
                                       }
                                   })

                    actionButton(title: alias.pinned ? "Unpin" : "Pin",
                                 systemImage: alias.pinned ? "pin.slash.fill" : "pin.fill") {
                        Vibration.soft.vibrate()
                        viewModel.update(option: .pinned(!alias.pinned))
                    }

                    actionButton(title: alias.enabled ? "Pause" : "Resume",
                                 systemImage: alias.enabled ? "pause.fill" : "play.fill") {
                        Vibration.soft.vibrate()
                        viewModel.toggle()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }

    private func actionButton(title: String,
                              systemImage: String,
                              action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.title3)
                    .foregroundStyle(Color.brand)
                    .frame(width: 56, height: 56)
                    .glassEffect(.regular.interactive(), in: Circle())
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
    }
}

private struct MailboxesSection: View {
    @ObservedObject var viewModel: AliasDetailViewModel
    @State private var selectedUrlString: String?

    var body: some View {
        Section(content: {
            NavigationLink(destination: {
                EditMailboxesView(viewModel: viewModel)
            }, label: {
                let allMailboxes = viewModel.alias.mailboxes.map(\.email).joined(separator: "\n")
                Text(allMailboxes)
                    .lineLimit(5)
            })
        }, header: {
            Text("Mailboxes")
        }, footer: {
            Button("What are mailboxes?") {
                selectedUrlString = Brand.addMailboxDocsUrlString
            }
            .foregroundColor(.brand)
        })
        .betterSafariView(urlString: $selectedUrlString)
    }
}

private struct NameSection: View {
    @ObservedObject var viewModel: AliasDetailViewModel
    @State private var showingEditView = false

    var body: some View {
        Section(content: {
            Text(viewModel.alias.name.flatMap { $0.isEmpty ? nil : $0 } ?? "Add a display name")
                .foregroundStyle(viewModel.alias.name?.isEmpty == false ? Color.primary : Color.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .contentShape(Rectangle())
                .sheet(isPresented: $showingEditView) {
                    EditDisplayNameView(viewModel: viewModel)
                }
                .onTapGesture {
                    showingEditView = true
                }
        }, header: {
            Text("Display name")
        }, footer: {
            Text("Your display name when sending emails from this alias")
        })
    }
}

private struct NotesSection: View {
    @ObservedObject var viewModel: AliasDetailViewModel
    @State private var showingEditView = false

    var body: some View {
        Section(content: {
            Text(viewModel.alias.note.flatMap { $0.isEmpty ? nil : $0 } ?? "Add a note, e.g. where it's used")
                .foregroundStyle(viewModel.alias.note?.isEmpty == false ? Color.primary : Color.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .contentShape(Rectangle())
                .sheet(isPresented: $showingEditView) {
                    EditNotesView(viewModel: viewModel)
                }
                .onTapGesture {
                    showingEditView = true
                }
        }, header: {
            Text("Notes")
        })
    }
}

private struct ActivitiesSection: View {
    @ObservedObject var viewModel: AliasDetailViewModel
    @Binding var copiedText: String?

    var body: some View {
        Section(content: {
            if viewModel.alias.noActivities {
                Text("No activities")
                    .foregroundColor(.secondary)
                    .font(.body.italic())
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                ForEach(0..<min(5, viewModel.activities.count), id: \.self) { index in
                    let activity = viewModel.activities[index]
                    ActivityView(copiedText: $copiedText, activity: activity)
                        .padding(.vertical, 4)
                }

                if viewModel.activities.count > 5 {
                    NavigationLink(destination: {
                        AllActivitiesView(viewModel: viewModel)
                    }, label: {
                        Text("Show all activities")
                    })
                }
            }
        }, header: {
            VStack(alignment: .leading) {
                Text("Last 14 days activities")
                if !viewModel.activities.isEmpty {
                    HStack(spacing: 10) {
                        section(action: .forward,
                                count: viewModel.alias.forwardCount)
                        section(action: .reply,
                                count: viewModel.alias.replyCount)
                        section(action: .block,
                                count: viewModel.alias.blockCount)
                    }
                    .textCase(nil)
                    .padding(.vertical, 6)
                }
            }
        })
        .onAppear {
            viewModel.getMoreActivitiesIfNeed(currentActivity: nil)
        }
    }

    private func section(action: ActivityAction, count: Int) -> some View {
        VStack(spacing: 4) {
            Image(systemName: action.iconSystemName)
                .font(.footnote.weight(.bold))
                .foregroundStyle(action.color)
            Text(count, format: .number.notation(.compactName))
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(.primary)
            Text(action.title)
                .font(.caption2.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        // swiftlint:disable:next empty_count
        .opacity(count == 0 ? 0.6 : 1)
    }
}

private struct ActivityView: View {
    @Binding var copiedText: String?
    let activity: AliasActivity

    var body: some View {
        Menu(content: {
            Section {
                Button(action: {
                    Vibration.soft.vibrate()
                    copiedText = activity.reverseAlias
                    UIPasteboard.general.string = activity.reverseAlias
                }, label: {
                    Label("Copy reverse-alias\n(with display name)", systemImage: "doc.on.doc")
                })

                Button(action: {
                    Vibration.soft.vibrate()
                    copiedText = activity.reverseAliasAddress
                    UIPasteboard.general.string = activity.reverseAliasAddress
                }, label: {
                    Label("Copy reverse-alias\n(without display name)", systemImage: "doc.on.doc")
                })
            }

            Section {
                Button(action: {
                    if let mailToUrl = URL(string: "mailto:\(activity.reverseAliasAddress)") {
                        UIApplication.shared.open(mailToUrl)
                    }
                }, label: {
                    Label("Open default email client", systemImage: "paperplane")
                })
            }
        }, label: {
            HStack(spacing: 12) {
                Image(systemName: activity.action.iconSystemName)
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(activity.action.color.gradient, in: Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(activity.action == .reply ? activity.to : activity.from)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    Text("\(activity.dateString) (\(activity.relativeDateString))")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        })
    }
}

private struct AllActivitiesView: View {
    @ObservedObject var viewModel: AliasDetailViewModel
    @State private var copiedText: String?

    var body: some View {
        Form {
            Section(content: {
                ForEach(0..<viewModel.activities.count, id: \.self) { index in
                    let activity = viewModel.activities[index]
                    ActivityView(copiedText: $copiedText, activity: activity)
                        .padding(.vertical, 4)
                        .onAppear {
                            viewModel.getMoreActivitiesIfNeed(currentActivity: activity)
                        }
                }
            }, header: {
                Text("Last 14 days activities")
            })
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                AliasNavigationTitleView(alias: viewModel.alias)
            }
        }
        .alertToastCopyMessage($copiedText)
    }
}

// MARK: - Edit views

private struct EditMailboxesView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AliasDetailViewModel
    @State private var selectedIds: [Int] = []

    init(viewModel: AliasDetailViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
        _selectedIds = .init(initialValue: viewModel.alias.mailboxes.map(\.id))
    }

    var body: some View {
        Form {
            Section(content: {
                ForEach(viewModel.mailboxes, id: \.id) { mailbox in
                    HStack {
                        Text(mailbox.email)
                            .foregroundColor(mailbox.verified ? .primary : .secondary)
                        Spacer()
                        if selectedIds.contains(mailbox.id) {
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
                        if selectedIds.contains(mailbox.id), selectedIds.count > 1 {
                            selectedIds.removeAll { $0 == mailbox.id }
                        } else if !selectedIds.contains(mailbox.id) {
                            selectedIds.append(mailbox.id)
                        }
                    }
                }
            }, header: {
                if !viewModel.mailboxes.isEmpty {
                    Text("Mailboxes")
                }
            }, footer: {
                if !viewModel.mailboxes.isEmpty {
                    PrimaryButton(title: "Save") {
                        viewModel.update(option: .mailboxIds(selectedIds))
                    }
                    .padding(.vertical)
                }
            })
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                AliasNavigationTitleView(alias: viewModel.alias)
            }
        }
        .onAppear {
            if viewModel.mailboxes.isEmpty {
                viewModel.getMailboxes()
            }
        }
        .onReceive(viewModel.$isUpdating.dropFirst()) { isUpdating in
            if !isUpdating {
                dismiss()
            }
        }
        .alertToastLoading(isPresenting: $viewModel.isLoadingMailboxes)
        .alertToastLoading(isPresenting: $viewModel.isUpdating)
        .alertToastError($viewModel.updatingError)
    }
}

private struct EditNotesView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AliasDetailViewModel
    @State private var notes = ""

    var body: some View {
        NavigationView {
            Form {
                Section(content: {
                    AdaptiveTextEditor(text: $notes)
                        .disabled(viewModel.isUpdating)
                        .frame(minHeight: 150)
                }, header: {
                    Text("Notes")
                }, footer: {
                    PrimaryButton(title: "Save") {
                        viewModel.update(option: .note(notes))
                    }
                    .padding(.vertical)
                })
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    AliasNavigationTitleView(alias: viewModel.alias)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelButton
                }
            }
        }
        .accentColor(.brand)
        .onAppear {
            notes = viewModel.alias.note ?? ""
        }
        .onReceive(viewModel.$isUpdating.dropFirst()) { isUpdating in
            if !isUpdating {
                dismiss()
            }
        }
        .alertToastLoading(isPresenting: $viewModel.isUpdating)
        .alertToastError($viewModel.updatingError)
    }

    private var cancelButton: some View {
        Button(action: dismiss.callAsFunction) {
            Text("Cancel")
        }
    }
}

private struct EditDisplayNameView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: AliasDetailViewModel
    @State private var displayName = ""

    init(viewModel: AliasDetailViewModel) {
        _viewModel = .init(initialValue: viewModel)
        _displayName = .init(initialValue: viewModel.alias.name ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section(content: {
                    TextField("", text: $displayName)
                        .disabled(viewModel.isUpdating)
                }, header: {
                    Text("Display name")
                }, footer: {
                    PrimaryButton(title: "Save") {
                        viewModel.update(option: .name(displayName))
                    }
                    .padding(.vertical)
                })
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    AliasNavigationTitleView(alias: viewModel.alias)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelButton
                }
            }
        }
        .accentColor(.brand)
        .onReceive(viewModel.$isUpdating.dropFirst()) { isUpdating in
            if !isUpdating {
                dismiss()
            }
        }
        .alertToastLoading(isPresenting: $viewModel.isUpdating)
        .alertToastError($viewModel.updatingError)
    }

    private var cancelButton: some View {
        Button(action: dismiss.callAsFunction) {
            Text("Cancel")
        }
    }
}
