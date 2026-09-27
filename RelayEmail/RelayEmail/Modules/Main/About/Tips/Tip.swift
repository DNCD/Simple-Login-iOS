//
//  Tip.swift
//  RelayEmail
//
//  Created by Thanh-Nhon Nguyen on 02/02/2022.
//

import Foundation

enum OnboardingTip {
    case touchId, faceId, contextMenu, fullScreen, siriShortcuts, shareExtension, keyboardExtension

    var title: String {
        switch self {
        case .touchId:
            "Touch ID"
        case .faceId:
            "Face ID"
        case .contextMenu:
            "Swipe & long press"
        case .fullScreen:
            "Full screen mode"
        case .siriShortcuts:
            "Siri & Shortcuts"
        case .shareExtension:
            "Share extension"
        case .keyboardExtension:
            "Keyboard extension"
        }
    }

    var description: String {
        switch self {
        case .touchId:
            "Restrict unwelcome access to your RelayEmail app on this device with Touch ID."
        case .faceId:
            "Restrict unwelcome access to your RelayEmail app on this device with Face ID."
        case .contextMenu:
            // swiftlint:disable:next line_length
            "Swipe an alias to copy, pin, disable or delete it. Long press to reveal even more options.\nTry it with the test alias below 👇"
        case .fullScreen:
            // swiftlint:disable:next line_length
            "Show your aliases to other people easily without dictating. In alias detail page, either tap on alias or choose \"Enter Full Screen\" option."
        case .siriShortcuts:
            // swiftlint:disable:next line_length
            "Say \"Hey Siri, create a random alias with RelayEmail\", assign it to the Action button, or long press the app icon for quick actions."
        case .shareExtension:
            // swiftlint:disable:next line_length
            "Create aliases on the fly without leaving the current context. Whenever you need to create an alias for a website, simply \"share\" the URL and choose RelayEmail."
        case .keyboardExtension:
            // swiftlint:disable:next line_length
            "Type your aliases without opening the RelayEmail app. Go to Settings ➝ General ➝ Keyboard ➝ Keyboards to enable the RelayEmail keyboard as well as \"Allow Full Access\""
        }
    }

    var action: String? {
        switch self {
        case .contextMenu, .faceId, .touchId, .siriShortcuts:
            nil
        case .fullScreen, .shareExtension:
            "Try it"
        case .keyboardExtension:
            "Open settings"
        }
    }

    var systemIconName: String {
        switch self {
        case .touchId:
            "touchid"
        case .faceId:
            "faceid"
        case .contextMenu:
            "hand.draw"
        case .fullScreen:
            "iphone"
        case .siriShortcuts:
            "waveform.circle"
        case .shareExtension:
            "square.and.arrow.up"
        case .keyboardExtension:
            "keyboard"
        }
    }
}
