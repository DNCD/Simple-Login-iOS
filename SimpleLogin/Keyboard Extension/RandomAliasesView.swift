//
//  RandomAliasesView.swift
//  Keyboard Extension
//
//  Created by Nhon Nguyen on 29/04/2022.
//

import SwiftUI

struct RandomAliasesView: View {
    @ObservedObject var viewModel: KeyboardContentViewModel

    var body: some View {
        VStack(spacing: 14) {
            Text("New random alias")
                .font(.headline)

            Button(action: {
                viewModel.random(mode: .word)
            }, label: {
                Label("Random words", systemImage: "textformat.abc")
                    .frame(maxWidth: 260)
            })
            .buttonStyle(.glassProminent)
            .tint(.brand)

            Button(action: {
                viewModel.random(mode: .uuid)
            }, label: {
                Label("Random characters", systemImage: "number")
                    .frame(maxWidth: 260)
            })
            .buttonStyle(.glass)
        }
        .controlSize(.large)
    }
}
