//
//  PrimaryButton.swift
//  RelayEmail
//
//  Created by Nhon Nguyen on 20/02/2022.
//

import SwiftUI

struct PrimaryButton: View {
    @Environment(\.isEnabled) private var isEnabled
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
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(LinearGradient.brand,
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.brand.opacity(isEnabled ? 0.3 : 0), radius: 10, y: 4)
                .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        })
        .buttonStyle(PressableButtonStyle())
    }
}

/// Subtle scale-down effect when pressed, like system buttons
struct PressableButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
