//
//  AppearanceMode.swift
//  RelayEmail
//

import SwiftUI
import UIKit

enum AppearanceMode: Int, CaseIterable, Identifiable {
    // swiftlint:disable:next explicit_enum_raw_value
    case system = 0, light, dark

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var systemImageName: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max.fill"
        case .dark: "moon.fill"
        }
    }

    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: .unspecified
        case .light: .light
        case .dark: .dark
        }
    }

    /// Applies the appearance to every window immediately (no restart needed),
    /// including sheets, alerts & menus
    func apply() {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .forEach { $0.overrideUserInterfaceStyle = userInterfaceStyle }
    }

    /// Migrates the legacy "Force dark mode" toggle to the new appearance setting
    static func migrateLegacySettingIfNeeded(_ defaults: UserDefaults = .standard) {
        guard defaults.object(forKey: kAppearance) == nil else { return }
        if defaults.bool(forKey: kForceDarkMode) {
            defaults.set(AppearanceMode.dark.rawValue, forKey: kAppearance)
        }
        defaults.removeObject(forKey: kForceDarkMode)
    }
}
