//
//  AliasCompactView.swift
//  RelayEmail
//
//  Created by Thanh-Nhon Nguyen on 26/10/2021.
//

import SimpleLoginPackage
import SwiftUI

struct AliasCompactView: View {
    @AppStorage(kAliasDisplayMode) private var displayMode: AliasDisplayMode = .default
    @State private var showingAliasEmailSheet = false
    @State private var showingAliasEmailFullScreen = false
    let alias: Alias
    let onCopy: () -> Void
    let onSendMail: () -> Void
    let onToggle: () -> Void
    let onPin: () -> Void
    let onUnpin: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: displayMode == .compact ? .center : .top, spacing: 12) {
            AliasAvatar(email: alias.email,
                        isEnabled: alias.enabled,
                        size: displayMode == .compact ? 32 : 40)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(alias.email)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(alias.enabled ? Color.primary : Color.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    if alias.pinned {
                        Image(systemName: "pin.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                            .accessibilityLabel(Text("Pinned"))
                    }
                }

                if displayMode != .compact {
                    subtitle
                }

                if displayMode == .default, !alias.noActivities {
                    ActivitiesView(alias: alias)
                        .padding(.top, 2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Toggle("Active", isOn: Binding(get: {
                alias.enabled
            }, set: { _ in
                onToggle()
            }))
            .labelsHidden()
            .tint(.brand)
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
        .fullScreenCover(isPresented: $showingAliasEmailFullScreen) {
            AliasEmailView(email: alias.email)
        }
        .sheet(isPresented: $showingAliasEmailSheet) {
            AliasEmailView(email: alias.email)
        }
        .contextMenu {
            Section {
                Button(action: onCopy) {
                    Label.copy
                }

                ShareLink(item: alias.email) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }

                Button(action: onSendMail) {
                    Label.contacts
                }
            }

            Section {
                Button(action: {
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        showingAliasEmailSheet = true
                    } else {
                        showingAliasEmailFullScreen = true
                    }
                }, label: {
                    Label.enterFullScreen
                })
            }

            Section {
                if alias.pinned {
                    Button(action: onUnpin) {
                        Label.unpin
                    }
                } else {
                    Button(action: onPin) {
                        Label.pin
                    }
                }
            }

            Section {
                DeleteMenuButton(action: onDelete)
            }
        }
    }
}

private extension AliasCompactView {
    @ViewBuilder
    var subtitle: some View {
        Group {
            if let note = alias.note, !note.isEmpty {
                Label(note, systemImage: "note.text")
            } else if let activity = alias.latestActivity {
                Label {
                    Text("\(activity.contact.email) · \(activity.relativeDateString)")
                } icon: {
                    Image(systemName: activity.action.iconSystemName)
                        .foregroundStyle(activity.action.color)
                }
            } else {
                Label("Created \(alias.relativeCreationDateString)", systemImage: "clock")
            }
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .lineLimit(1)
        .labelStyle(CompactLabelStyle())
    }
}

/// Icon + title with a tight spacing, for secondary lines
private struct CompactLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 4) {
            configuration.icon
                .font(.caption)
            configuration.title
        }
    }
}

private struct ActivitiesView: View {
    let alias: Alias

    var body: some View {
        HStack(spacing: 12) {
            metric(action: .forward, count: alias.forwardCount)
            metric(action: .reply, count: alias.replyCount)
            metric(action: .block, count: alias.blockCount)
        }
        .font(.caption.weight(.medium))
        .monospacedDigit()
    }

    private func metric(action: ActivityAction, count: Int) -> some View {
        HStack(spacing: 3) {
            Image(systemName: action.iconSystemName)
                .foregroundStyle(action.color)
            Text("\(count)")
                .foregroundStyle(.secondary)
        }
        // swiftlint:disable:next empty_count
        .opacity(count == 0 ? 0.5 : 1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(count) \(action.title)"))
    }
}

struct AliasCompactView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            AliasCompactView(alias: .ccohen,
                             onCopy: {},
                             onSendMail: {},
                             onToggle: {},
                             onPin: {},
                             onUnpin: {},
                             onDelete: {})
            AliasCompactView(alias: .claypool,
                             onCopy: {},
                             onSendMail: {},
                             onToggle: {},
                             onPin: {},
                             onUnpin: {},
                             onDelete: {})
        }
        .accentColor(.brand)
    }
}
