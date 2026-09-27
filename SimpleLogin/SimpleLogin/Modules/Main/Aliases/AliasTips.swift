//
//  AliasTips.swift
//  RelayEmail
//
//  In-context hints powered by TipKit
//

import SwiftUI
import TipKit

struct SwipeActionsTip: Tip {
    var title: Text {
        Text("Swipe for quick actions")
    }

    var message: Text? {
        Text("Swipe right to copy or pin an alias. Swipe left to disable or delete it.")
    }

    var image: Image? {
        Image(systemName: "hand.draw")
    }
}

struct SiriShortcutsTip: Tip {
    var title: Text {
        Text("Create aliases hands-free")
    }

    var message: Text? {
        // swiftlint:disable:next line_length
        Text("Say \"Create a random alias with \(Brand.name)\" to Siri, add it to the Action button, or long press the app icon.")
    }

    var image: Image? {
        Image(systemName: "waveform")
    }
}
