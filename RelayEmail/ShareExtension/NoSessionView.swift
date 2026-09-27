//
//  NoSessionView.swift
//  ShareExtension
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
            Text("This Share Extension helps you create aliases on the fly without leaving your current context.\nPlease open the RelayEmail app and log in first in order to use this feature.")
                .multilineTextAlignment(.center)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}
