//
//  AliasesView.swift
//  RelayEmail
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import Combine
import CoreData
import SimpleLoginPackage
import SwiftUI
import TipKit

struct AliasesView: View {
    @StateObject private var viewModel: AliasesViewModel
    @Binding private var createdAlias: Alias?
    @Binding private var searchRequested: Bool
    @State private var showingCreatedAliasAlert = false
    @State private var showingUpdatingAlert = false
    @State private var showingSearchView = false
    @State private var showingDeleteConfirmationAlert = false
    @State private var copiedEmail: String?
    @State private var selectedAlias: Alias?
    @State private var aliasToShowDetails: Alias?
    @State private var selectedLink: Link?
    private let onCreateAlias: () -> Void
    private let onUpgrade: () -> Void
    private let swipeActionsTip = SwipeActionsTip()

    enum Modal {
        case search, create
    }

    enum Link {
        case details, contacts
    }

    init(session: Session,
         reachabilityObserver: ReachabilityObserver,
         managedObjectContext: NSManagedObjectContext,
         createdAlias: Binding<Alias?>,
         searchRequested: Binding<Bool>,
         onCreateAlias: @escaping () -> Void,
         onUpgrade: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: .init(session: session,
                                                     reachabilityObserver: reachabilityObserver,
                                                     managedObjectContext: managedObjectContext))
        _createdAlias = createdAlias
        _searchRequested = searchRequested
        self.onCreateAlias = onCreateAlias
        self.onUpgrade = onUpgrade
    }

    var body: some View {
        let showingCopiedEmailAlert = Binding<Bool>(get: {
            copiedEmail != nil
        }, set: { isShowing in
            if !isShowing {
                copiedEmail = nil
            }
        })

        NavigationView {
            ZStack {
                NavigationLink(tag: Link.details,
                               selection: $selectedLink,
                               destination: {
                                   AliasDetailWrapperView(selectedAlias: $selectedAlias,
                                                          session: viewModel.session,
                                                          onUpdateAlias: { updatedAlias in
                                                              if createdAlias?.id == updatedAlias.id {
                                                                  createdAlias = updatedAlias
                                                              }
                                                              viewModel.update(alias: updatedAlias)
                                                          },
                                                          onDeleteAlias: { deletedAlias in
                                                              if deletedAlias.id == createdAlias?.id {
                                                                  createdAlias = nil
                                                              }
                                                              viewModel.remove(alias: deletedAlias)
                                                          },
                                                          onUpgrade: onUpgrade)
                                       .ignoresSafeArea(.keyboard)
                                       .onAppear {
                                           if UIDevice.current.userInterfaceIdiom != .phone {
                                               selectedLink = nil
                                           }
                                       }
                               },
                               label: {
                                   EmptyView()
                               })

                NavigationLink(tag: Link.contacts,
                               selection: $selectedLink,
                               destination: {
                                   if let selectedAlias {
                                       AliasContactsView(alias: selectedAlias,
                                                         session: viewModel.session,
                                                         onUpgrade: onUpgrade)
                                           .onAppear {
                                               if UIDevice.current.userInterfaceIdiom != .phone {
                                                   selectedLink = nil
                                               }
                                           }
                                   } else {
                                       EmptyView()
                                   }
                               },
                               label: {
                                   EmptyView()
                               })

                ScrollViewReader { proxy in
                    aliasesList(proxy: proxy)
                }
                .ignoresSafeArea(.keyboard)
                .navigationBarTitleDisplayMode(.inline)
                .offlineLabelled(reachable: viewModel.reachabilityObserver.reachable)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Picker("", selection: $viewModel.selectedStatus) {
                            ForEach(AliasStatus.allCases, id: \.self) { status in
                                Text(status.description)
                                    .tag(status)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .labelsHidden()
                    }

                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: {
                            Vibration.light.vibrate()
                            showingSearchView = true
                        }, label: {
                            Label("Search", systemImage: "magnifyingglass")
                        })
                        .keyboardShortcut("f", modifiers: .command)

                        Menu(content: {
                            createMenuContent
                        }, label: {
                            Label("Create alias", systemImage: "plus")
                        }, primaryAction: onCreateAlias)
                        .keyboardShortcut("n", modifiers: .command)
                    }
                }
                .onChange(of: searchRequested) { _, requested in
                    if requested {
                        showingSearchView = true
                        searchRequested = false
                    }
                }
                .sheet(isPresented: $showingSearchView) {
                    SearchAliasesView(session: viewModel.session,
                                      onUpdateAlias: { updatedAlias in
                                          viewModel.update(alias: updatedAlias)
                                      },
                                      onDeleteAlias: { deletedAlias in
                                          if deletedAlias.id == createdAlias?.id {
                                              createdAlias = nil
                                          }
                                          viewModel.remove(alias: deletedAlias)
                                      },
                                      onUpgrade: onUpgrade)
                }
            }

            DetailPlaceholderView.aliasDetails
        }
        .slNavigationView()
        .onReceive(Just(viewModel.isUpdating)) { isUpdating in
            showingUpdatingAlert = isUpdating
        }
        .alert(isPresented: $showingDeleteConfirmationAlert) {
            guard let selectedAlias else {
                return Alert(title: Text("selectedAlias is nil"))
            }

            return Alert.deleteConfirmation(alias: selectedAlias) {
                viewModel.delete(alias: selectedAlias)
            }
        }
        .alertToastLoading(isPresenting: $showingUpdatingAlert)
        .alertToastCopyMessage(isPresenting: showingCopiedEmailAlert, message: copiedEmail)
        .alertToastError($viewModel.error)
        .alertToastCompletionMessage(isPresenting: $showingCreatedAliasAlert,
                                     title: "Created",
                                     subTitle: createdAlias?.email ?? "")
    }
}

private extension AliasesView {
    func aliasesList(proxy: ScrollViewProxy) -> some View {
        List {
            if let stats = viewModel.stats {
                StatsView(stats: stats)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            if !viewModel.aliases.isEmpty {
                TipView(swipeActionsTip)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)

                if let createdAlias {
                    switch (createdAlias.enabled, viewModel.selectedStatus) {
                    case (false, .inactive), (true, .active), (true, .all):
                        aliasCompactView(for: createdAlias)
                    default:
                        EmptyView()
                    }
                }

                ForEach(viewModel.aliases, id: \.id) { alias in
                    if alias.id == createdAlias?.id {
                        EmptyView()
                    } else {
                        // swiftlint:disable:next todo
                        // TODO: Workaround a SwiftUI bug
                        // that doesn't update AliasCompactView's context menu
                        // https://stackoverflow.com/a/70159934
                        if alias.pinned {
                            aliasCompactView(for: alias)
                        } else {
                            aliasCompactView(for: alias)
                        }
                    }
                }
            }

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color(.systemGroupedBackground))
        .overlay {
            if viewModel.aliases.isEmpty, !viewModel.isLoading, viewModel.error == nil {
                emptyView
            }
        }
        .safeAreaInset(edge: .bottom, alignment: .trailing) {
            FloatingCreateButton(action: onCreateAlias)
                .contextMenu { createMenuContent }
                .padding(20)
        }
        .refreshable { await viewModel.refresh() }
        .animation(.default, value: viewModel.stats != nil)
        .onReceive(Just(createdAlias)) { createdAlias in
            if let createdAlias {
                if !viewModel.isHandled(createdAlias) {
                    showingCreatedAliasAlert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        withAnimation {
                            proxy.scrollTo(createdAlias.id, anchor: .top)
                        }
                    }
                }
                viewModel.handleCreatedAlias(createdAlias)
            }
        }
        .onReceive(Just(viewModel.updatedAlias)) { updatedAlias in
            if let updatedAlias, updatedAlias.id == createdAlias?.id {
                createdAlias = updatedAlias
            }
        }
    }

    @ViewBuilder
    func aliasCompactView(for alias: Alias) -> some View {
        let hightlight = alias.id == createdAlias?.id
        AliasCompactView(alias: alias,
                         onCopy: {
                             Vibration.soft.vibrate()
                             copiedEmail = alias.email
                             UIPasteboard.general.string = alias.email
                         },
                         onSendMail: {
                             Vibration.soft.vibrate()
                             selectedAlias = alias
                             selectedLink = .contacts
                         },
                         onToggle: {
                             Vibration.soft.vibrate()
                             viewModel.toggle(alias: alias)
                         },
                         onPin: {
                             viewModel.update(alias: alias, option: .pinned(true))
                         },
                         onUnpin: {
                             viewModel.update(alias: alias, option: .pinned(false))
                         },
                         onDelete: {
                             Vibration.warning.vibrate(fallBackToOldSchool: true)
                             selectedAlias = alias
                             showingDeleteConfirmationAlert = true
                         })
                         .id(alias.id)
                         .onAppear {
                             viewModel.getMoreAliasesIfNeed(currentAlias: alias)
                         }
                         .onTapGesture {
                             selectedAlias = alias
                             selectedLink = .details
                         }
                         .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                         .listRowSeparator(.hidden)
                         .listRowBackground(
                             RoundedRectangle(cornerRadius: 20, style: .continuous)
                                 .fill(hightlight ?
                                     Color.brand.opacity(0.15) : Color(.secondarySystemGroupedBackground))
                                 .padding(.horizontal, 12)
                                 .padding(.vertical, 5)
                         )
                         .swipeActions(edge: .leading, allowsFullSwipe: true) {
                             Button {
                                 Vibration.soft.vibrate()
                                 copiedEmail = alias.email
                                 UIPasteboard.general.string = alias.email
                                 swipeActionsTip.invalidate(reason: .actionPerformed)
                             } label: {
                                 Label.copy
                             }
                             .tint(.brand)

                             Button {
                                 viewModel.update(alias: alias, option: .pinned(!alias.pinned))
                                 swipeActionsTip.invalidate(reason: .actionPerformed)
                             } label: {
                                 alias.pinned ? Label.unpin : Label.pin
                             }
                             .tint(.orange)
                         }
                         .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                             Button {
                                 Vibration.warning.vibrate(fallBackToOldSchool: true)
                                 selectedAlias = alias
                                 showingDeleteConfirmationAlert = true
                                 swipeActionsTip.invalidate(reason: .actionPerformed)
                             } label: {
                                 Label.delete
                             }
                             .tint(.red)

                             Button {
                                 Vibration.soft.vibrate()
                                 viewModel.toggle(alias: alias)
                                 swipeActionsTip.invalidate(reason: .actionPerformed)
                             } label: {
                                 alias.enabled ? Label.deactivate : Label.activate
                             }
                             .tint(alias.enabled ? .gray : .green)
                         }
    }

    @ViewBuilder
    var createMenuContent: some View {
        Button(action: onCreateAlias) {
            Label("Custom alias", systemImage: "square.and.pencil")
        }

        Button(action: {
            AppRouter.shared.pendingRoute = .randomAlias
        }, label: {
            Label("Random alias", systemImage: "wand.and.stars")
        })
    }

    @ViewBuilder
    var emptyView: some View {
        switch viewModel.selectedStatus {
        case .all:
            ContentUnavailableView(label: {
                Label("No aliases yet", systemImage: "at.badge.plus")
            }, description: {
                Text("Create an alias for every website to keep your real email address private.")
            }, actions: {
                Button(action: onCreateAlias) {
                    Text("Create your first alias")
                        .padding(.horizontal, 8)
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.capsule)
            })
        case .active:
            ContentUnavailableView("No active aliases",
                                   systemImage: "checkmark.circle",
                                   description: Text("Aliases that forward emails show up here."))
        case .inactive:
            ContentUnavailableView("No inactive aliases",
                                   systemImage: "circle.dashed",
                                   description: Text("Disabled aliases block every email they receive."))
        }
    }
}

enum AliasStatus: CustomStringConvertible, CaseIterable {
    case all, active, inactive

    var description: String {
        switch self {
        case .all: "All"
        case .active: "Active"
        case .inactive: "Inactive"
        }
    }
}
