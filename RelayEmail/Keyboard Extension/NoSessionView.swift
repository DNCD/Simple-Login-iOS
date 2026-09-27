//
//  NoSessionView.swift
//  Keyboard Extension
//
//  Created by Thanh-Nhon Nguyen on 30/01/2022.
//

import SwiftUI

struct NoSessionView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image("LogoWithoutName")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
            Text("RelayEmail")
                .font(.title3.weight(.bold))
            // swiftlint:disable:next line_length
            Text("Please open the RelayEmail app and log in. Then go to Settings ➝ General ➝ Keyboard ➝ Keyboards and give the RelayEmail keyboard full access.")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}
