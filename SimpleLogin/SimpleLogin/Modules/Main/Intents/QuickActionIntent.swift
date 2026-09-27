//
//  QuickActionIntent.swift
//  RelayEmail
//
//  Shared by the app and the widget extension. Widgets & Control Center buttons run this intent,
//  which opens the app and asks it to perform a quick action.
//

import AppIntents
import Foundation

enum QuickActionKind: String, AppEnum {
    case random = "random"
    case create = "create"
    case search = "search"

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Quick Action")

    static let caseDisplayRepresentations: [QuickActionKind: DisplayRepresentation] = [
        .random: DisplayRepresentation(title: "Random alias", image: .init(systemName: "wand.and.stars")),
        .create: DisplayRepresentation(title: "Custom alias", image: .init(systemName: "plus")),
        .search: DisplayRepresentation(title: "Search aliases", image: .init(systemName: "magnifyingglass"))
    ]
}

struct OpenQuickActionIntent: AppIntent {
    static let title: LocalizedStringResource = "Open RelayEmail Quick Action"
    static let openAppWhenRun = true
    static let isDiscoverable = false

    @Parameter(title: "Action", default: .random)
    var action: QuickActionKind

    init() {}

    init(action: QuickActionKind) {
        self.action = action
    }

    func perform() async throws -> some IntentResult {
        UserDefaults.shared?.set(action.rawValue, forKey: kPendingQuickAction)
        return .result()
    }
}
