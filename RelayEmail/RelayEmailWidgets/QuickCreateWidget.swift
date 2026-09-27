//
//  QuickCreateWidget.swift
//  RelayEmailWidgets
//
//  Home Screen & Lock Screen widget to create aliases in one tap.
//

import AppIntents
import SwiftUI
import WidgetKit

struct QuickCreateEntry: TimelineEntry {
    let date: Date
}

struct QuickCreateProvider: TimelineProvider {
    func placeholder(in _: Context) -> QuickCreateEntry {
        QuickCreateEntry(date: .now)
    }

    func getSnapshot(in _: Context, completion: @escaping (QuickCreateEntry) -> Void) {
        completion(QuickCreateEntry(date: .now))
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<QuickCreateEntry>) -> Void) {
        completion(Timeline(entries: [QuickCreateEntry(date: .now)], policy: .never))
    }
}

struct QuickCreateWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "QuickCreateWidget", provider: QuickCreateProvider()) { _ in
            QuickCreateWidgetView()
        }
        .configurationDisplayName("Quick Create")
        .description("Create a new alias in one tap.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

struct QuickCreateWidgetView: View {
    @Environment(\.widgetFamily) private var family

    var body: some View {
        content
            .containerBackground(for: .widget) {
                if family == .systemSmall || family == .systemMedium {
                    LinearGradient.brand
                } else {
                    AccessoryWidgetBackground()
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        case .accessoryCircular:
            Image(systemName: "wand.and.stars")
                .font(.title2.weight(.semibold))
                .widgetAccentable()
                .widgetURL(URL(string: "\(Brand.urlScheme)://random"))
        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 2) {
                Text(Brand.name)
                    .font(.headline)
                    .widgetAccentable()
                Label("New random alias", systemImage: "wand.and.stars")
                    .font(.caption)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .widgetURL(URL(string: "\(Brand.urlScheme)://random"))
        case .systemMedium:
            VStack(alignment: .leading, spacing: 12) {
                header
                HStack(spacing: 10) {
                    actionButton(.random, title: "Random", systemImage: "wand.and.stars")
                    actionButton(.create, title: "Custom", systemImage: "plus")
                    actionButton(.search, title: "Search", systemImage: "magnifyingglass")
                }
            }
        default:
            VStack(alignment: .leading, spacing: 10) {
                header
                Spacer(minLength: 0)
                actionButton(.random, title: "Random", systemImage: "wand.and.stars")
                actionButton(.create, title: "Custom", systemImage: "plus")
            }
        }
    }

    private var header: some View {
        HStack(spacing: 8) {
            Image("LogoWithoutName")
                .resizable()
                .scaledToFit()
                .frame(width: 26, height: 26)
            Text(Brand.name)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
            Spacer(minLength: 0)
        }
    }

    private func actionButton(_ action: QuickActionKind, title: String, systemImage: String) -> some View {
        Button(intent: OpenQuickActionIntent(action: action)) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 36)
                .background(Color.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
