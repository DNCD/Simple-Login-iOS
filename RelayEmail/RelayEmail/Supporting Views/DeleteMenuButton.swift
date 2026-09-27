//
//  DeleteMenuButton.swift
//  RelayEmail
//
//  Created by Nhon Nguyen on 13/02/2022.
//

import SwiftUI

struct DeleteMenuButton: View {
    let action: () -> Void

    var body: some View {
        let label: () -> Label = { .delete }
        let hapticAction: () -> Void = {
            Vibration.warning.vibrate(fallBackToOldSchool: true)
            action()
        }
        Button(role: .destructive, action: hapticAction, label: label)
    }
}
