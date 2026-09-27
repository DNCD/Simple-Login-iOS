//
//  AboutView.swift
//  RelayEmail
//
//  Created by Thanh-Nhon Nguyen on 02/09/2021.
//

import SwiftUI

private let kVersionName =
    (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String) ?? "?"
private let kBuildNumber =
    (Bundle.main.infoDictionary?["CFBundleVersion"] as? String) ?? "?"

struct AboutView: View {
    @State private var selectedUrlString: String?

    var body: some View {
        Form {
            Section {
                VStack(spacing: 12) {
                    LogoWithNameView(size: 72)
                    Text("Protect your inbox with email aliases")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                .listRowBackground(Color.clear)
            }

            Section(header: Text("How it works")) {
                Image("Schema")
                    .resizable()
                    .scaledToFit()
                NavigationLink(destination: {
                                   HowItWorksView()
                               },
                               label: {
                                   Text("More detail")
                               })
            }

            Section {
                linkLabel(title: "Website",
                          systemImageName: "globe",
                          color: .blue,
                          urlString: Brand.websiteUrlString)

                linkLabel(title: "Dashboard",
                          systemImageName: "rectangle.grid.2x2.fill",
                          color: .brand,
                          urlString: Brand.dashboardUrlString)

                linkLabel(title: "Help & documentation",
                          systemImageName: "book.fill",
                          color: .orange,
                          urlString: Brand.docsUrlString)

                linkLabel(title: "Frequently asked questions",
                          systemImageName: "questionmark.bubble.fill",
                          color: .green,
                          urlString: Brand.faqUrlString)
            }

            Section {
                linkLabel(title: "Terms and conditions",
                          systemImageName: "doc.plaintext.fill",
                          color: .gray,
                          urlString: Brand.termsUrlString)

                linkLabel(title: "Privacy policy",
                          systemImageName: "hand.raised.fill",
                          color: .indigo,
                          urlString: Brand.privacyUrlString)

                linkLabel(title: "Security",
                          systemImageName: "lock.shield.fill",
                          color: .teal,
                          urlString: Brand.securityUrlString)
            }

            Section(content: {
                URLButton(urlString: "mailto:\(Brand.supportEmail)") {
                    Label("Email us", systemImage: "envelope.fill")
                }
            }, header: {
                Text("Have a question?")
            }, footer: {
                Text("Version \(kVersionName) (Build \(kBuildNumber))")
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top)
            })
        }
        .navigationTitle("About \(Brand.name)")
        .betterSafariView(urlString: $selectedUrlString)
    }

    private func linkLabel(title: String,
                           systemImageName: String,
                           color: Color,
                           urlString: String) -> some View {
        Button(action: {
            selectedUrlString = urlString
        }, label: {
            Label(title: {
                Text(title)
                    .foregroundStyle(Color(.label))
            }, icon: {
                Image(systemName: systemImageName)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 28, height: 28)
                    .background(color.gradient, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            })
        })
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
