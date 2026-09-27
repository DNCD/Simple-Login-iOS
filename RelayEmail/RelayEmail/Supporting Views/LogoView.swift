//
//  LogoView.swift
//  RelayEmail
//
//  Created by Nhon Nguyen on 12/02/2022.
//

import SwiftUI

/// The RelayEmail app mark
struct LogoView: View {
    var size: CGFloat = 96

    var body: some View {
        Image("LogoWithoutName")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .shadow(color: Color.brand.opacity(0.35), radius: size / 6, y: size / 12)
            .accessibilityHidden(true)
    }
}

/// App mark + name, used on the log in & sign up screens
struct LogoWithNameView: View {
    var size: CGFloat = 96

    var body: some View {
        VStack(spacing: 12) {
            LogoView(size: size)
            Text(Brand.name)
                .font(.system(size: size / 3, weight: .heavy, design: .rounded))
                .foregroundStyle(.primary)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(Brand.name))
    }
}

struct LogoView_Previews: PreviewProvider {
    static var previews: some View {
        LogoWithNameView()
    }
}
