//
//  SecondaryButton.swift
//  RelayEmail
//
//  Created by Nhon Nguyen on 25/02/2022.
//

import SwiftUI

struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.brand)
                .frame(maxWidth: .infinity, minHeight: 52)
                .background(Color.brand.opacity(0.12),
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .buttonStyle(PressableButtonStyle())
    }
}
