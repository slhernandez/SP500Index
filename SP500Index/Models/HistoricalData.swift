//
//  HistoricalData.swift
//  SP500Index
//
//  Historical price data model for charts
//

import Foundation

struct HistoricalDataPoint: Identifiable, Equatable {
    let id = UUID()
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
}

struct HistoricalData {
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
}
