//
//  RelayEmailIntents.swift
//  RelayEmail
//
//  Siri, Shortcuts, Spotlight & Action button support.
//  App Shortcuts are available automatically after install, no setup required.
//

import AppIntents
import SimpleLoginPackage
import UIKit

enum RelayEmailIntentError: Error, CustomLocalizedStringResourceConvertible {
    case notLoggedIn
    case invalidApiUrl

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .notLoggedIn:
            "You're not logged in. Open RelayEmail and log in first."
        case .invalidApiUrl:
            "The API URL is invalid. Check it in RelayEmail's log in screen."
        }
    }
}

enum AliasStyleAppEnum: String, AppEnum {
    case word = "word"
    case uuid = "uuid"

    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Alias Style")

    static let caseDisplayRepresentations: [AliasStyleAppEnum: DisplayRepresentation] = [
        .word: DisplayRepresentation(title: "Random words",
                                     image: .init(systemName: "textformat.abc")),
        .uuid: DisplayRepresentation(title: "Random characters",
                                     image: .init(systemName: "number"))
    ]

    var randomMode: RandomMode {
        switch self {
        case .word: .word
        case .uuid: .uuid
        }
    }
}

/// Creates a random alias in the background, without opening the app
struct CreateRandomAliasIntent: AppIntent {
    static let title: LocalizedStringResource = "Create Random Alias"
    static let description = IntentDescription("Creates a random RelayEmail alias and copies it to the clipboard.",
                                               categoryName: "Aliases")

    @Parameter(title: "Style", default: .word)
    var style: AliasStyleAppEnum

    @Parameter(title: "Note", description: "Optional note, e.g. the website you're signing up for")
    var note: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Create a random alias using \(\.$style)") {
            \.$note
        }
    }

    func perform() async throws -> some IntentResult & ReturnsValue<String> & ProvidesDialog {
        guard let apiKey = KeychainService.shared.getApiKey() else {
            throw RelayEmailIntentError.notLoggedIn
        }
        guard let baseURL = URL(string: Preferences.shared.apiUrl) else {
            throw RelayEmailIntentError.invalidApiUrl
        }
        let apiService = APIService(baseURL: baseURL,
                                    session: .init(configuration: .relayEmail),
                                    printDebugInformation: false)
        let endpoint = RandomAliasEndpoint(apiKey: apiKey.value,
                                           note: note,
                                           mode: style.randomMode,
                                           hostname: nil)
        let alias = try await apiService.execute(endpoint)
        await MainActor.run {
            UIPasteboard.general.string = alias.email
        }
        return .result(value: alias.email,
                       dialog: "Created \(alias.email) and copied it to your clipboard.")
    }
}

/// Opens the app on the "create alias" screen
struct NewAliasIntent: AppIntent {
    static let title: LocalizedStringResource = "New Custom Alias"
    static let description = IntentDescription("Opens RelayEmail to create a custom alias.",
                                               categoryName: "Aliases")
    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            AppRouter.shared.pendingRoute = .createAlias
        }
        return .result()
    }
}

/// Opens the app on the alias search
struct SearchAliasesIntent: AppIntent {
    static let title: LocalizedStringResource = "Search Aliases"
    static let description = IntentDescription("Opens RelayEmail and starts searching your aliases.",
                                               categoryName: "Aliases")
    static let openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            AppRouter.shared.pendingRoute = .search
        }
        return .result()
    }
}

struct RelayEmailShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: CreateRandomAliasIntent(),
                    phrases: [
                        "Create a random alias with \(.applicationName)",
                        "New random \(.applicationName) alias",
                        "Make a \(.applicationName) alias",
                        "Generate an email alias in \(.applicationName)"
                    ],
                    shortTitle: "Random Alias",
                    systemImageName: "wand.and.stars")

        AppShortcut(intent: NewAliasIntent(),
                    phrases: [
                        "Create a custom alias with \(.applicationName)",
                        "New \(.applicationName) custom alias"
                    ],
                    shortTitle: "Custom Alias",
                    systemImageName: "plus.circle")

        AppShortcut(intent: SearchAliasesIntent(),
                    phrases: [
                        "Search my \(.applicationName) aliases",
                        "Find an alias in \(.applicationName)"
                    ],
                    shortTitle: "Search Aliases",
                    systemImageName: "magnifyingglass")
    }
}
