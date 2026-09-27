//
//  PremiumView.swift
//  RelayEmail
//
//  Created by Nhon Nguyen on 25/02/2022.
//

import SwiftUI

struct PremiumView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                PremiumHeroView(title: "You're Premium",
                                subtitle: "Thank you for supporting \(Brand.name).")

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(kCapacities) {
                        CapacityView(capacity: $0, checkmarkColor: .brand)
                    }
                    Text("...and all of our upcoming features.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemGroupedBackground),
                            in: RoundedRectangle(cornerRadius: 22, style: .continuous))
            }
            .padding()
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
        }
        .navigationBarTitle("Premium plan", displayMode: .inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(gradientBackground)
    }

    private var gradientBackground: some View {
        LinearGradient(colors: [Color.brand.opacity(0.25), Color(.systemGroupedBackground)],
                       startPoint: .top,
                       endPoint: .center)
            .ignoresSafeArea()
    }
}

/// Crown badge, title and subtitle shown at the top of the upgrade & premium screens
struct PremiumHeroView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: "crown.fill")
                .font(.system(size: 34, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 80, height: 80)
                .background(LinearGradient.brand, in: Circle())
                .shadow(color: Color.brand.opacity(0.4), radius: 16, y: 8)
            Text(title)
                .font(.system(.title, design: .rounded, weight: .bold))
                .multilineTextAlignment(.center)
            Text(subtitle)
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
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
