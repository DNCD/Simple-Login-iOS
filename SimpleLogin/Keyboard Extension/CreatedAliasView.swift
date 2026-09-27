//
//  CreatedAliasView.swift
//  Keyboard Extension
//
//  Created by Nhon Nguyen on 29/04/2022.
//

import SimpleLoginPackage
import SwiftUI

struct CreatedAliasView: View {
    @ObservedObject var viewModel: KeyboardContentViewModel
    let alias: Alias
    let onSelectAlias: (Alias) -> Void

    var body: some View {
        VStack(spacing: 20) {
            AliasView(alias: alias)
                .onTapGesture {
                    onSelectAlias(alias)
                }

            Text("Tap the alias to insert it")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Button(action: {
                viewModel.handleCreatedAlias()
            }, label: {
                Label("Back", systemImage: "chevron.backward")
            })
            .buttonStyle(.glass)
        }
        .padding(.horizontal, 44)
    }
}
