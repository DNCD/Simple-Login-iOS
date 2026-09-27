//
//  DesignSystem.swift
//  RelayEmail
//
//  Small reusable building blocks that give the app a consistent, native iOS 26 look.
//

import SwiftUI

// MARK: - Settings-style icon tiles

/// Renders a label's icon inside a colored rounded square, like the iOS Settings app
struct TileLabelStyle: LabelStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        Label {
            configuration.title
        } icon: {
            configuration.icon
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 30, height: 30)
                .background(color.gradient, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
}

extension LabelStyle where Self == TileLabelStyle {
    static func tile(_ color: Color) -> TileLabelStyle {
        TileLabelStyle(color: color)
    }
}

// MARK: - Alias avatar

/// Monogram avatar with a stable gradient derived from the alias
struct AliasAvatar: View {
    let email: String
    var isEnabled = true
    var size: CGFloat = 40

    private static let palettes: [[Color]] = [
        [.indigo, .purple],
        [.blue, .cyan],
        [.teal, .green],
        [.orange, .pink],
        [.pink, .purple],
        [.mint, .teal],
        [.purple, .blue],
        [.red, .orange]
    ]

    private var palette: [Color] {
        // Stable across launches (unlike `hashValue`)
        let seed = email.unicodeScalars.reduce(0) { ($0 &* 31 &+ Int($1.value)) % 997 }
        return Self.palettes[seed % Self.palettes.count]
    }

    private var monogram: String {
        email.first(where: \.isLetter).map { String($0).uppercased() } ?? "@"
    }

    var body: some View {
        Text(monogram)
            .font(.system(size: size * 0.42, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background {
                Circle()
                    .fill(LinearGradient(colors: isEnabled ? palette : [.gray, .gray.opacity(0.7)],
                                         startPoint: .topLeading,
                                         endPoint: .bottomTrailing))
            }
            .overlay(alignment: .bottomTrailing) {
                if !isEnabled {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: size * 0.36))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, .gray)
                        .background(Circle().fill(Color(.systemBackground)))
                        .offset(x: 2, y: 2)
                }
            }
            .accessibilityHidden(true)
    }
}

// MARK: - Animated brand background

/// Slowly moving mesh gradient in brand colors
struct BrandMeshBackground: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30)) { context in
            let time = context.date.timeIntervalSinceReferenceDate
            let offset = Float(sin(time / 4)) * 0.12
            let points: [SIMD2<Float>] = [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.5 + offset, 0.5 - offset], [1, 0.5],
                [0, 1], [0.5, 1], [1, 1]
            ]
            let colors: [Color] = [
                .indigo, .purple, .blue,
                .purple, .brand, .indigo,
                .blue, .indigo, .purple
            ]
            MeshGradient(width: 3, height: 3, points: points, colors: colors)
        }
        .ignoresSafeArea()
    }
}

struct DesignSystem_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            Label("Face ID", systemImage: "faceid")
                .labelStyle(.tile(.green))
            HStack {
                AliasAvatar(email: "shopping@relay.example")
                AliasAvatar(email: "news@relay.example", isEnabled: false)
            }
        }
    }
}
