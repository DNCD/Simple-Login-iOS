//
//  OfflineLabelledViewModifier.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 12/03/2022.
//

import SwiftUI

/// Shows a floating "You're offline" pill on top of the content
struct OfflineLabelledViewModifier: ViewModifier {
    let reachable: Bool

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .top) {
                if !reachable {
                    Label("You're offline", systemImage: "wifi.slash")
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .glassEffect(.regular.tint(Color.red.opacity(0.35)), in: Capsule())
                        .padding(.top, 4)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.spring, value: reachable)
    }
}

extension View {
    func offlineLabelled(reachable: Bool) -> some View {
        modifier(OfflineLabelledViewModifier(reachable: reachable))
    }
}
