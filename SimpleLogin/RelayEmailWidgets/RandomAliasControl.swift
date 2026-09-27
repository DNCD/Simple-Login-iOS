//
//  RandomAliasControl.swift
//  RelayEmailWidgets
//
//  Control Center, Lock Screen & Action button control.
//

import AppIntents
import SwiftUI
import WidgetKit

struct RandomAliasControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "RandomAliasControl") {
            ControlWidgetButton(action: OpenQuickActionIntent(action: .random)) {
                Label("Random Alias", systemImage: "wand.and.stars")
            }
        }
        .displayName("Random Alias")
        .description("Create a random RelayEmail alias and copy it.")
    }
}
