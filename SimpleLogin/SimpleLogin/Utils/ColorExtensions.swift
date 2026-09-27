//
//  ColorExtensions.swift
//  RelayEmail
//
//  Created by Thanh-Nhon Nguyen on 29/10/2021.
//

import SwiftUI

extension UIColor {
    static var brand: UIColor {
        UIColor(named: "AccentColor") ?? .systemIndigo
    }

    static var proton: UIColor {
        UIColor(named: "ProtonColor") ?? .purple
    }
}

extension Color {
    static var brand: Color {
        Color(.brand)
    }

    /// Secondary brand color used for highlights (e.g. the relay badge in the app icon)
    static var brandSecondary: Color {
        Color(red: 0.13, green: 0.83, blue: 0.93)
    }

    static var proton: Color {
        Color(.proton)
    }
}

extension LinearGradient {
    /// Signature RelayEmail gradient (indigo ➝ violet), matching the app icon
    static var brand: LinearGradient {
        LinearGradient(colors: [Color(red: 0.31, green: 0.27, blue: 0.90),
                                Color(red: 0.58, green: 0.20, blue: 0.92)],
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
    }
}
