//
//  PremiumView.swift
//  SimpleLogin
//
//  Created by Nhon Nguyen on 25/02/2022.
//

import SwiftUI

struct PremiumView: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("Your current premium plan".uppercased())
                    .font(.title3)
                    .fontWeight(.heavy)
                    .padding([.horizontal, .top])
                    .padding(.bottom, 4)
                    .foregroundColor(.brand)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(kCapacities) {
                        CapacityView(capacity: $0, checkmarkColor: .brand)
                    }
                    Text("...and all of our upcoming features.")
                }
            }
        }
        .navigationBarTitle("Premium plan", displayMode: .inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(gradientBackground)
    }

    private var gradientBackground: some View {
        LinearGradient(gradient: .init(colors: [
            .brand.opacity(0.05),
            .brand.opacity(0.1),
            .brand.opacity(0.15),
            .brand.opacity(0.2)
        ]),
        startPoint: .top,
        endPoint: .bottom)
            .edgesIgnoringSafeArea([.leading, .trailing, .bottom])
    }
}

private let kCapacities: [Capacity] = [
    .unlimitedBandWidth,
    .unlimitedReplySend,
    .browserExtensions,
    .totp,
    .signInWithRelayEmail,
    .unlimitedAliases,
    .unlimitedMailboxes,
    .unlimitedDomains,
    .catchAllDomain,
    .fiveSubdomains,
    .fiftyDirectories,
    .pgp
]
