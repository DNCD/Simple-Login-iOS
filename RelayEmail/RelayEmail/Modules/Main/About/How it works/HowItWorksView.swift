//
//  HowItWorksView.swift
//  RelayEmail
//
//  Created by Nhon Nguyen on 26/02/2022.
//

import SwiftUI

struct HowItWorksView: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                VStack {
                    Text("Shield your inbox with email aliases")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }

                StepView(step: .one)
                StepView(step: .two)
                StepView(step: .three)
            }
            .padding(.top, 20)
            .padding()
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("How it works")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct StepView: View {
    let step: HowItWorkStep

    var body: some View {
        VStack {
            Text(step.title)
                .font(.title3)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            Image(step.imageName)
                .resizable()
                .scaledToFit()
            Text(step.description)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
