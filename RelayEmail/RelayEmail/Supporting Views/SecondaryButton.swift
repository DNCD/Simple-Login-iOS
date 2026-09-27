//
//  SecondaryButton.swift
//  RelayEmail
//
//  Created by Nhon Nguyen on 25/02/2022.
//

import SwiftUI

/// Regular Liquid Glass button
struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.tint)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.glass)
        .controlSize(.extraLarge)
    }
}
