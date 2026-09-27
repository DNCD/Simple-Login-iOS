//
//  FloatingCreateButton.swift
//  RelayEmail
//

import SwiftUI

/// Floating "+" button used to create aliases.
/// Uses Liquid Glass on iOS 26 and later, a brand gradient otherwise.
struct FloatingCreateButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            content
        }
        .buttonStyle(PressableButtonStyle())
        .accessibilityLabel(Text("Create alias"))
        .accessibilityHint(Text("Long press for more options"))
    }

    @ViewBuilder
    private var content: some View {
        let icon = Image(systemName: "plus")
            .font(.title2.weight(.semibold))
            .frame(width: 60, height: 60)
        #if compiler(>=6.2)
        if #available(iOS 26, *) {
            icon
                .foregroundStyle(.white)
                .glassEffect(.regular.tint(Color.brand).interactive(), in: Circle())
        } else {
            gradientIcon(icon)
        }
        #else
        gradientIcon(icon)
        #endif
    }

    private func gradientIcon(_ icon: some View) -> some View {
        icon
            .foregroundStyle(.white)
            .background(LinearGradient.brand, in: Circle())
            .shadow(color: Color.brand.opacity(0.4), radius: 12, y: 6)
    }
}

struct FloatingCreateButton_Previews: PreviewProvider {
    static var previews: some View {
        FloatingCreateButton {}
    }
}
