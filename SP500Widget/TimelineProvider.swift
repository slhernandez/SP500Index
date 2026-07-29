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

    private let dataService = StockDataService()
    private let refreshTimeoutNanoseconds: UInt64 = 3_000_000_000

    func placeholder(in context: Context) -> StockEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (StockEntry) -> Void) {
        let entry = loadCurrentEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StockEntry>) -> Void) {
        Task {
            let entry = await loadFreshEntry()
            let refreshDate = calculateNextRefresh()
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }

    // MARK: - Private Methods

    private func loadCurrentEntry() -> StockEntry {
        let quote = SharedStorage.loadQuote()
        let historicalData = SharedStorage.loadHistoricalData()
        return StockEntry.from(
            quote: quote,
            historicalData: historicalData,
            updatedAt: SharedStorage.lastUpdated
        )
    }

    private func loadFreshEntry() async -> StockEntry {
        let cachedEntry = loadCurrentEntry()
        let symbol = SharedStorage.selectedSymbol

        do {
            let (quote, historicalData) = try await fetchWidgetData(symbol: symbol)
            let updatedAt = Date()

            SharedStorage.saveWidgetData(
                quote: quote,
                historicalData: historicalData,
                updatedAt: updatedAt
            )

            return StockEntry.from(
                quote: quote,
                historicalData: historicalData,
                updatedAt: updatedAt
            )
        } catch {
            // Never leave the widget in its placeholder state while a request is slow or unavailable.
            return cachedEntry
        }
    }

    private func fetchWidgetData(symbol: String) async throws -> (StockQuote, HistoricalData) {
        try await withThrowingTaskGroup(
            of: (StockQuote, HistoricalData).self,
            returning: (StockQuote, HistoricalData).self
        ) { group in
            group.addTask {
                async let quoteTask = self.dataService.fetchQuote(symbol: symbol)
                async let historicalTask = self.dataService.fetchHistoricalData(symbol: symbol, range: .oneDay)
                return try await (quoteTask, historicalTask)
            }

            group.addTask {
                try await Task.sleep(nanoseconds: refreshTimeoutNanoseconds)
                throw URLError(.timedOut)
            }

            defer { group.cancelAll() }

            guard let result = try await group.next() else {
                throw URLError(.unknown)
            }
            return result
        }
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
