//
//  NoHorizontalPaddingModifier.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 29/04/2022.
//

import SwiftUI

struct NoHorizontalPaddingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, -20)
    }
}

extension View {
    func noHorizontalPadding() -> some View {
        modifier(NoHorizontalPaddingModifier())
    }
}
