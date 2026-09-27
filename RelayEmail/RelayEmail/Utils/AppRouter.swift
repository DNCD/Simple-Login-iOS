//
//  AppRouter.swift
//  RelayEmail
//
//  Routes external entry points (home screen quick actions, deep links, Spotlight,
//  Siri & Shortcuts) to the right place inside the app.
//

import CoreSpotlight
import SwiftUI
import UIKit

enum AppRoute: Equatable {
    /// Show the aliases tab
    case aliases
    /// Open the "create alias" sheet
    case createAlias
    /// Create a random alias right away and copy it
    case randomAlias
    /// Open the alias search
    case search
    /// Copy a given alias email to the clipboard (e.g. from a Spotlight result)
    case copy(email: String)
}

/// Home screen quick actions declared in Info.plist (`UIApplicationShortcutItems`)
enum QuickAction: String {
    case createAlias = "com.relayemail.quickaction.create"
    case randomAlias = "com.relayemail.quickaction.random"
    case search = "com.relayemail.quickaction.search"

    var route: AppRoute {
        switch self {
        case .createAlias: .createAlias
        case .randomAlias: .randomAlias
        case .search: .search
        }
    }
}

/// Must only be used from the main thread
final class AppRouter: ObservableObject {
    static let shared = AppRouter()

    @Published var pendingRoute: AppRoute?

    private init() {}

    func consume() {
        pendingRoute = nil
    }

    /// Handles `relayemail://create`, `relayemail://random`, `relayemail://search` & `relayemail://aliases`
    @discardableResult
    func handle(url: URL) -> Bool {
        guard url.scheme?.lowercased() == Brand.urlScheme else { return false }
        switch url.host?.lowercased() {
        case "create", "new":
            pendingRoute = .createAlias
        case "random":
            pendingRoute = .randomAlias
        case "search":
            pendingRoute = .search
        case "aliases", .none:
            pendingRoute = .aliases
        default:
            return false
        }
        return true
    }

    @discardableResult
    func handle(shortcutItem: UIApplicationShortcutItem) -> Bool {
        guard let action = QuickAction(rawValue: shortcutItem.type) else { return false }
        pendingRoute = action.route
        return true
    }

    /// Picks up a quick action requested by a widget or a Control Center button
    func consumePendingQuickAction() {
        guard let defaults = UserDefaults.shared,
              let rawValue = defaults.string(forKey: kPendingQuickAction) else { return }
        defaults.removeObject(forKey: kPendingQuickAction)
        switch rawValue {
        case "random":
            pendingRoute = .randomAlias
        case "create":
            pendingRoute = .createAlias
        case "search":
            pendingRoute = .search
        default:
            break
        }
    }

    /// Handles a tap on a Spotlight search result
    func handle(spotlightActivity userActivity: NSUserActivity) {
        guard let email = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String else { return }
        pendingRoute = .copy(email: email)
    }
}

/// Scene delegate used only to receive home screen quick actions,
/// everything else is handled by SwiftUI.
final class SceneDelegate: NSObject, UIWindowSceneDelegate {
    func scene(_: UIScene,
               willConnectTo _: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        if let shortcutItem = connectionOptions.shortcutItem {
            AppRouter.shared.handle(shortcutItem: shortcutItem)
        }
    }

    func windowScene(_: UIWindowScene,
                     performActionFor shortcutItem: UIApplicationShortcutItem,
                     completionHandler: @escaping (Bool) -> Void) {
        completionHandler(AppRouter.shared.handle(shortcutItem: shortcutItem))
    }
}
