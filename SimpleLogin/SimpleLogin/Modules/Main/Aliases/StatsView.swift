//
// StatsView.swift
// RelayEmail - Created on 07/02/2024.
// Copyright (c) 2024 Proton Technologies AG
//
// This file is part of SimpleLogin.
//
// SimpleLogin is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// SimpleLogin is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with SimpleLogin. If not, see https://www.gnu.org/licenses/.
//

import SimpleLoginPackage
import SwiftUI

struct StatsView: View {
    let stats: Stats

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            cell(title: "Aliases",
                 description: "All time",
                 systemImageName: "at",
                 color: .brand,
                 count: stats.aliasCount)
            cell(title: "Forwarded",
                 description: "Last 14 days",
                 systemImageName: "arrowshape.turn.up.right.fill",
                 color: .green,
                 count: stats.forwardCount)
            cell(title: "Replies",
                 description: "Last 14 days",
                 systemImageName: "arrowshape.turn.up.left.fill",
                 color: .blue,
                 count: stats.replyCount)
            cell(title: "Blocked",
                 description: "Last 14 days",
                 systemImageName: "hand.raised.fill",
                 color: .red,
                 count: stats.blockCount)
        }
    }
}

private extension StatsView {
    func cell(title: String,
              description: String,
              systemImageName: String,
              color: Color,
              count: Int) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: systemImageName)
                    .font(.footnote.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(color.gradient, in: Circle())
                Spacer()
                Text("\(count)")
                    .font(.title2.weight(.bold))
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }
            Text(title)
                .font(.subheadline.weight(.semibold))
            Text(description)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
