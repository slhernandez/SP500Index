//
//  StockEntry.swift
//  SP500Widget
//
//  Timeline entry model for widget
//

import WidgetKit
import Foundation

struct StockEntry: TimelineEntry {
    let date: Date
    let symbol: String
    let name: String
    let price: Double
    let priceChange: Double
    let percentChange: Double
    let marketState: MarketState
    let historicalData: [ChartDataPoint]?

    // Additional stats for large widget
    let open: Double?
    let dayHigh: Double?
    let dayLow: Double?
    let fiftyTwoWeekHigh: Double?
    let fiftyTwoWeekLow: Double?

    var isPositive: Bool {
        priceChange >= 0
    }

    // Simplified chart data point for widget
    struct ChartDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let price: Double
    }
}

// MARK: - Factory Methods

extension StockEntry {
    /// Create entry from shared storage data
    static func from(
        quote: StockQuote?,
        historicalData: HistoricalData?,
        updatedAt: Date? = nil
    ) -> StockEntry {
        if let quote = quote {
            let chartData = historicalData?.dataPoints.map { point in
                ChartDataPoint(date: point.date, price: point.close)
            }

            return StockEntry(
                date: updatedAt ?? quote.lastUpdated,
                symbol: quote.symbol,
                name: quote.name,
                price: quote.currentPrice,
                priceChange: quote.priceChange,
                percentChange: quote.percentChange,
                marketState: quote.marketState,
                historicalData: chartData,
                open: quote.open,
                dayHigh: quote.dayHigh,
                dayLow: quote.dayLow,
                fiftyTwoWeekHigh: quote.fiftyTwoWeekHigh,
                fiftyTwoWeekLow: quote.fiftyTwoWeekLow
            )
        } else {
            return .placeholder
        }
    }

    /// Placeholder entry for loading state
    static var placeholder: StockEntry {
        StockEntry(
            date: Date(),
            symbol: "FXAIX",
            name: "Fidelity 500 Index Fund",
            price: 198.45,
            priceChange: 2.31,
            percentChange: 1.18,
            marketState: .closed,
            historicalData: generatePlaceholderChartData(),
            open: 196.50,
            dayHigh: 199.00,
            dayLow: 195.80,
            fiftyTwoWeekHigh: 210.00,
            fiftyTwoWeekLow: 165.00
        )
    }

    /// Preview entry for SwiftUI previews
    static var preview: StockEntry {
        placeholder
    }

    private static func generatePlaceholderChartData() -> [ChartDataPoint] {
        let calendar = Calendar.current
        var points: [ChartDataPoint] = []
        var price = 185.0

        for dayOffset in (0..<30).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { continue }
            price += Double.random(in: -2.0...2.5)
            price = max(price, 170)
            points.append(ChartDataPoint(date: date, price: price))
        }

        return points
    }
}
