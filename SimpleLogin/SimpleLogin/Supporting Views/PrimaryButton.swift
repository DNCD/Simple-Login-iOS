//
//  PrimaryButton.swift
//  RelayEmail
//
//  Created by Nhon Nguyen on 20/02/2022.
//

import SwiftUI

/// Prominent Liquid Glass button tinted with the brand color
struct PrimaryButton: View {
    let title: String
    let action: () async -> Void

    var body: some View {
        Button(action: {
            Task {
                await action()
            }
        }, label: {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
        })
        .buttonStyle(.glassProminent)
        .controlSize(.extraLarge)
        .tint(.brand)
    }
}
