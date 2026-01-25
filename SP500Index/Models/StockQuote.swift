//
//  StockQuote.swift
//  SP500Index
//
//  Stock quote data model for current price information
//

import Foundation

struct StockQuote: Codable, Equatable {
    let symbol: String
    let name: String
    let currentPrice: Double
    let previousClose: Double
    let currency: String
    let marketState: MarketState
    let lastUpdated: Date

    var priceChange: Double {
        currentPrice - previousClose
    }

    var percentChange: Double {
        guard previousClose != 0 else { return 0 }
        return (priceChange / previousClose) * 100
    }

    var isPositive: Bool {
        priceChange >= 0
    }
}

enum MarketState: String, Codable {
    case preMarket = "PRE"
    case regular = "REGULAR"
    case postMarket = "POST"
    case closed = "CLOSED"

    var displayText: String {
        switch self {
        case .preMarket: return "Pre-Market"
        case .regular: return "Market Open"
        case .postMarket: return "After Hours"
        case .closed: return "Market Closed"
        }
    }
}

// MARK: - Yahoo Finance API Response Models

struct YahooChartResponse: Codable {
    let chart: YahooChart
}

struct YahooChart: Codable {
    let result: [YahooChartResult]?
    let error: YahooError?
}

struct YahooError: Codable {
    let code: String
    let description: String
}

struct YahooChartResult: Codable {
    let meta: YahooMeta
    let timestamp: [Int]?
    let indicators: YahooIndicators
}

struct YahooMeta: Codable {
    let currency: String
    let symbol: String
    let regularMarketPrice: Double
    let chartPreviousClose: Double
    let exchangeName: String
    let instrumentType: String
    let regularMarketTime: Int

    // Market state fields
    let currentTradingPeriod: CurrentTradingPeriod?

    var previousClose: Double { chartPreviousClose }
}

struct CurrentTradingPeriod: Codable {
    let pre: TradingPeriod?
    let regular: TradingPeriod?
    let post: TradingPeriod?
}

struct TradingPeriod: Codable {
    let timezone: String
    let start: Int
    let end: Int
    let gmtoffset: Int
}

struct YahooIndicators: Codable {
    let quote: [YahooQuote]
    let adjclose: [YahooAdjClose]?
}

struct YahooQuote: Codable {
    let open: [Double?]?
    let high: [Double?]?
    let low: [Double?]?
    let close: [Double?]?
    let volume: [Int?]?
}

struct YahooAdjClose: Codable {
    let adjclose: [Double?]?
}
