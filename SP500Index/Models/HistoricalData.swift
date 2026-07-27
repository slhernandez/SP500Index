//
//  HistoricalData.swift
//  SP500Index
//
//  Historical price data model for charts
//

import Foundation

struct HistoricalDataPoint: Identifiable, Equatable, Codable {
    var id: Date { date } // Use date as stable identifier for Codable
    let date: Date
    let close: Double
    let open: Double?
    let high: Double?
    let low: Double?
    let volume: Int?

    init(date: Date, close: Double, open: Double? = nil, high: Double? = nil, low: Double? = nil, volume: Int? = nil) {
        self.date = date
        self.close = close
        self.open = open
        self.high = high
        self.low = low
        self.volume = volume
    }

    static func == (lhs: HistoricalDataPoint, rhs: HistoricalDataPoint) -> Bool {
        lhs.date == rhs.date && lhs.close == rhs.close
    }

    // Custom CodingKeys to exclude computed id
    private enum CodingKeys: String, CodingKey {
        case date, close, open, high, low, volume
    }
}

struct HistoricalData: Codable {
    let symbol: String
    let dataPoints: [HistoricalDataPoint]
    let timeRange: TimeRange
    let fetchedAt: Date

    var minPrice: Double {
        dataPoints.map(\.close).min() ?? 0
    }

    var maxPrice: Double {
        dataPoints.map(\.close).max() ?? 0
    }

    var priceRange: Double {
        maxPrice - minPrice
    }

    var startPrice: Double? {
        dataPoints.first?.close
    }

    var endPrice: Double? {
        dataPoints.last?.close
    }

    var periodChange: Double? {
        guard let start = startPrice, let end = endPrice else { return nil }
        return end - start
    }

    var periodPercentChange: Double? {
        guard let start = startPrice, let change = periodChange, start != 0 else { return nil }
        return (change / start) * 100
    }

    var isPositivePeriod: Bool {
        (periodChange ?? 0) >= 0
    }

    func displayPerformance(using quote: StockQuote?) -> (change: Double, percentChange: Double, isPositive: Bool)? {
        if timeRange == .oneDay,
           let quote,
           quote.symbol == symbol {
            return (quote.priceChange, quote.percentChange, quote.isPositive)
        }

        guard let change = periodChange, let percentChange = periodPercentChange else {
            return nil
        }

        return (change, percentChange, isPositivePeriod)
    }
}
