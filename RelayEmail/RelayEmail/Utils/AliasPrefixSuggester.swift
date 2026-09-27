//
//  AliasPrefixSuggester.swift
//  RelayEmail
//
//  Suggests alias prefixes with the on-device Apple Intelligence model.
//  Nothing leaves the device.
//

import Foundation
import FoundationModels

enum AliasPrefixSuggester {
    /// `false` when Apple Intelligence is unsupported, disabled or not ready yet
    static var isAvailable: Bool {
        SystemLanguageModel.default.isAvailable
    }

    static func suggestPrefixes(for context: String) async throws -> [String] {
        let session = LanguageModelSession(instructions: """
        You suggest short, memorable prefixes for email aliases.
        Answer with 4 prefixes, one per line, nothing else.
        Each prefix uses only lowercase letters, digits, dots, dashes or underscores, and is at most 20 characters.
        """)
        let response = try await session.respond(to: "Suggest alias prefixes for: \(context)")
        return sanitize(response.content)
    }

    static func sanitize(_ output: String) -> [String] {
        let allowed = Set("abcdefghijklmnopqrstuvwxyz0123456789._-")
        var prefixes = [String]()
        for line in output.split(whereSeparator: \.isNewline) {
            let candidate = String(line.lowercased().filter { allowed.contains($0) }.prefix(20))
                .trimmingCharacters(in: CharacterSet(charactersIn: "._-"))
            if !candidate.isEmpty, candidate.isValidPrefix, !prefixes.contains(candidate) {
                prefixes.append(candidate)
            }
        }
        return Array(prefixes.prefix(4))
    }
}
