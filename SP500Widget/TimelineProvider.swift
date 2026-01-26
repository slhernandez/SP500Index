//
//  TimelineProvider.swift
//  SP500Widget
//
//  Timeline provider for widget refresh scheduling
//

import WidgetKit
import Foundation

struct StockTimelineProvider: TimelineProvider {
    typealias Entry = StockEntry

    func placeholder(in context: Context) -> StockEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (StockEntry) -> Void) {
        let entry = loadCurrentEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StockEntry>) -> Void) {
        let entry = loadCurrentEntry()
        let refreshDate = calculateNextRefresh()

        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }

    // MARK: - Private Methods

    private func loadCurrentEntry() -> StockEntry {
        let quote = SharedStorage.loadQuote()
        let historicalData = SharedStorage.loadHistoricalData()
        return StockEntry.from(quote: quote, historicalData: historicalData)
    }

    private func calculateNextRefresh() -> Date {
        let calendar = Calendar.current
        let now = Date()

        // Get current time components in Eastern Time (market timezone)
        var easternCalendar = Calendar.current
        easternCalendar.timeZone = TimeZone(identifier: "America/New_York") ?? .current

        let hour = easternCalendar.component(.hour, from: now)
        let weekday = easternCalendar.component(.weekday, from: now)

        // Check if it's a weekend (1 = Sunday, 7 = Saturday)
        let isWeekend = weekday == 1 || weekday == 7

        // Market hours: 9:30 AM - 4:00 PM ET
        let isMarketHours = !isWeekend && hour >= 9 && hour < 16

        if isMarketHours {
            // During market hours: refresh every 15 minutes
            return calendar.date(byAdding: .minute, value: 15, to: now) ?? now.addingTimeInterval(900)
        } else {
            // Outside market hours: refresh every hour
            return calendar.date(byAdding: .hour, value: 1, to: now) ?? now.addingTimeInterval(3600)
        }
    }
}
