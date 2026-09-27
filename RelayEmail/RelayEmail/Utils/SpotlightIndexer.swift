//
//  SpotlightIndexer.swift
//  RelayEmail
//
//  Makes aliases searchable from the iOS home screen (Spotlight).
//  Tapping a result opens the app and copies the alias.
//

import CoreSpotlight
import SimpleLoginPackage
import SwiftUI
import UniformTypeIdentifiers

enum SpotlightIndexer {
    private static let domainIdentifier = "com.relayemail.aliases"

    @AppStorage(kSpotlightIndexingEnabled) private static var isEnabled = true

    static func index(_ aliases: [Alias]) {
        guard isEnabled, !aliases.isEmpty, CSSearchableIndex.isIndexingAvailable() else { return }
        let items = aliases.map { alias -> CSSearchableItem in
            let attributes = CSSearchableItemAttributeSet(contentType: .emailMessage)
            attributes.title = alias.email
            var description = alias.enabled ? "Active alias" : "Inactive alias"
            if let note = alias.note, !note.isEmpty {
                description += " · \(note)"
            }
            attributes.contentDescription = description
            attributes.keywords = keywords(for: alias)
            let item = CSSearchableItem(uniqueIdentifier: alias.email,
                                        domainIdentifier: domainIdentifier,
                                        attributeSet: attributes)
            item.expirationDate = .distantFuture
            return item
        }
        CSSearchableIndex.default().indexSearchableItems(items) { error in
            if let error {
                print("Spotlight indexing failed: \(error)")
            }
        }
    }

    static func remove(_ alias: Alias) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [alias.email]) { _ in }
    }

    static func removeAll() {
        CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [domainIdentifier]) { _ in }
    }

    private static func keywords(for alias: Alias) -> [String] {
        let parts = alias.email.split { "@._-+".contains($0) }.map(String.init)
        return [Brand.name, "alias", "email"] + parts + (alias.note.map { [$0] } ?? [])
    }
}
