//
//  UpgradeView.swift
//  RelayEmail
//
//  Created by Thanh-Nhon Nguyen on 28/12/2021.
//

import Combine
import SimpleLoginPackage
import SwiftUI

struct UpgradeView: View {
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewModel: UpgradeViewModel
    @State private var showingLoadingAlert = false
    @State private var showingThankAlert = false
    @State private var selectedUrlString: String?

    var onSubscription: () -> Void

    init(session: Session, onSubscription: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: .init(session: session))
        self.onSubscription = onSubscription
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                PremiumHeroView(title: "\(Brand.name) Premium",
                                subtitle: "Unlimited aliases, mailboxes and custom domains.")
                premiumPlanSection
                freePlanSection
                yearlyButton
                monthlyButton
                Button("Restore purchases") {
                    viewModel.restorePurchase()
                }
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity)
                // swiftlint:disable:next line_length
                Text("Subscription can be managed and canceled at anytime by going to Settings ➝ Your Apple ID ➝ Subscriptions.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .fixedSize(horizontal: false, vertical: true)
                termsAndPrivacyView
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
        }
        .navigationBarTitle("Upgrade", displayMode: .inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(gradientBackground)
        .onAppear {
            viewModel.retrieveProductsInfo()
        }
        .onReceive(Just(viewModel.isSubscribed)) { isSubscribed in
            showingThankAlert = isSubscribed
        }
        .onReceive(Just(viewModel.isLoading)) { isLoading in
            showingLoadingAlert = isLoading
        }
        .alertToastLoading(isPresenting: $showingLoadingAlert)
        .alertToastError($viewModel.error)
        .betterSafariView(urlString: $selectedUrlString)
        .alert(isPresented: $showingThankAlert) {
            Alert(title: Text("Thank you"),
                  message: Text("You are now a premium user 🎉"),
                  dismissButton: .default(Text("Got it 👍")) {
                      onSubscription()
                      presentationMode.wrappedValue.dismiss()
                  })
        }
    }

    private var gradientBackground: some View {
        LinearGradient(colors: [Color.brand.opacity(0.25), Color(.systemGroupedBackground)],
                       startPoint: .top,
                       endPoint: .center)
            .ignoresSafeArea()
    }

    private var freePlanSection: some View {
        DisclosureGroup(content: {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(kFreeCapacities) {
                    CapacityView(capacity: $0, checkmarkColor: nil)
                }
            }
            .padding(.top, 8)
        }, label: {
            Text("What's included in your free plan")
                .font(.subheadline.weight(.semibold))
        })
        .padding()
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var premiumPlanSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(kPremiumCapacities) {
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

    private var yearlyButton: some View {
        VStack(alignment: .leading) {
            if let yearlySubscription = viewModel.yearlySubscription {
                PrimaryButton(title: "Subscribe yearly \(yearlySubscription.localizedPrice)/year") {
                    viewModel.subscribeYearly()
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            Label("Best value · save 2 months", systemImage: "sparkles")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.brand)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var monthlyButton: some View {
        VStack(alignment: .leading) {
            if let monthlySubscription = viewModel.monthlySubscription {
                SecondaryButton(title: "Subscribe monthly \(monthlySubscription.localizedPrice)/month") {
                    viewModel.subscribeMonthly()
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            Text("A cup of ☕ per month to improve your privacy.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var termsAndPrivacyView: some View {
        HStack {
            Button(action: {
                selectedUrlString = Brand.termsUrlString
            }, label: {
                Text("Terms and condition")
                    .fontWeight(.semibold)
                    .foregroundColor(.brand)
            })

            Text("•")
                .foregroundColor(.secondary)

            Button(action: {
                selectedUrlString = Brand.privacyUrlString
            }, label: {
                Text("Privacy policy")
                    .fontWeight(.semibold)
                    .foregroundColor(.brand)
            })
        }
        .font(.callout)
    }
}

struct UpgradeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UpgradeView(session: .preview) {}
        }
    }
}

private let kFreeCapacities: [Capacity] = [
    .fifteenAliases,
    .unlimitedBandWidth,
    .oneMailbox,
    .browserExtensions,
    .totp,
    .signInWithRelayEmail
]

private let kPremiumCapacities: [Capacity] = [
    .everythingInFreePlan,
    .unlimitedAliases,
    .unlimitedReplySend,
    .unlimitedMailboxes,
    .unlimitedDomains,
    .catchAllDomain,
    .fiveSubdomains,
    .fiftyDirectories,
    .pgp
]
