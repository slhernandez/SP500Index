//
//  SP500Widget.swift
//  SP500Widget
//
//  Widget entry point for S&P 500 Index widget
//

import WidgetKit
import SwiftUI

@main
struct SP500Widget: Widget {
    let kind: String = "SP500Widget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StockTimelineProvider()) { entry in
            StockWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("S&P 500 Index")
        .description("Track S&P 500 index fund prices")
        .supportedFamilies(supportedFamilies)
    }

    private var supportedFamilies: [WidgetFamily] {
        #if os(iOS)
        return [
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular
        ]
        #else
        return [
            .systemSmall,
            .systemMedium,
            .systemLarge
        ]
        #endif
    }
}

// MARK: - Widget Entry View

struct StockWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: StockEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        #if os(iOS)
        case .accessoryCircular:
            AccessoryCircularView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        #endif
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Preview

#Preview(as: .systemSmall) {
    SP500Widget()
} timeline: {
    StockEntry.preview
}

#Preview(as: .systemMedium) {
    SP500Widget()
} timeline: {
    StockEntry.preview
}

#Preview(as: .systemLarge) {
    SP500Widget()
} timeline: {
    StockEntry.preview
}

#if os(iOS)
#Preview(as: .accessoryCircular) {
    SP500Widget()
} timeline: {
    StockEntry.preview
}

#Preview(as: .accessoryRectangular) {
    SP500Widget()
} timeline: {
    StockEntry.preview
}
#endif
