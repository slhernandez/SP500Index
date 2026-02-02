//
//  MarketCategory.swift
//  SP500Index
//
//  Market category and index quote models
//

import Foundation

struct MarketIndex: Codable, Identifiable {
    let symbol: String      // Yahoo Finance ticker (e.g., "^DJI")
    let displayName: String // Full name (e.g., "Dow Jones")
    let shortName: String   // Abbreviated (e.g., "DJI")

    var id: String { symbol }
}

enum MarketCategory: String, CaseIterable, Identifiable, Codable {
    case us
    case europe
    case asia
    case currencies
    case crypto
    case futures

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .us: return "U.S."
        case .europe: return "Europe"
        case .asia: return "Asia"
        case .currencies: return "Currencies"
        case .crypto: return "Crypto"
        case .futures: return "Futures"
        }
    }

    var indices: [MarketIndex] {
        switch self {
        case .us:
            return [
                MarketIndex(symbol: "^DJI", displayName: "Dow Jones", shortName: "DJI"),
                MarketIndex(symbol: "^GSPC", displayName: "S&P 500", shortName: "SPX"),
                MarketIndex(symbol: "^IXIC", displayName: "Nasdaq", shortName: "NDX")
            ]
        case .europe:
            return [
                MarketIndex(symbol: "^GDAXI", displayName: "DAX", shortName: "DAX"),
                MarketIndex(symbol: "^FTSE", displayName: "FTSE 100", shortName: "FTSE"),
                MarketIndex(symbol: "^FCHI", displayName: "CAC 40", shortName: "CAC")
            ]
        case .asia:
            return [
                MarketIndex(symbol: "^N225", displayName: "Nikkei", shortName: "N225"),
                MarketIndex(symbol: "000001.SS", displayName: "SSE", shortName: "SSE"),
                MarketIndex(symbol: "^HSI", displayName: "Hang Seng", shortName: "HSI")
            ]
        case .currencies:
            return [
                MarketIndex(symbol: "EURUSD=X", displayName: "EUR/USD", shortName: "EUR"),
                MarketIndex(symbol: "JPY=X", displayName: "USD/JPY", shortName: "JPY"),
                MarketIndex(symbol: "GBPUSD=X", displayName: "GBP/USD", shortName: "GBP")
            ]
        case .crypto:
            return [
                MarketIndex(symbol: "BTC-USD", displayName: "Bitcoin", shortName: "BTC"),
                MarketIndex(symbol: "ETH-USD", displayName: "Ethereum", shortName: "ETH"),
                MarketIndex(symbol: "SOL-USD", displayName: "Solana", shortName: "SOL")
            ]
        case .futures:
            return [
                MarketIndex(symbol: "YM=F", displayName: "Dow Futures", shortName: "DJF"),
                MarketIndex(symbol: "ES=F", displayName: "S&P Futures", shortName: "ESF"),
                MarketIndex(symbol: "NQ=F", displayName: "Nasdaq Futures", shortName: "NQF")
            ]
        }
    }
}

struct IndexQuote: Codable, Identifiable {
    let symbol: String
    let displayName: String
    let shortName: String
    let currentPrice: Double
    let previousClose: Double

    var id: String { symbol }

    var percentChange: Double {
        guard previousClose != 0 else { return 0 }
        return ((currentPrice - previousClose) / previousClose) * 100
    }

    var isPositive: Bool {
        currentPrice >= previousClose
    }

    /// Factory method to create from StockQuote and MarketIndex
    init(from quote: StockQuote, index: MarketIndex) {
        self.symbol = quote.symbol
        self.displayName = index.displayName
        self.shortName = index.shortName
        self.currentPrice = quote.currentPrice
        self.previousClose = quote.previousClose
    }

    /// Direct initializer for testing/previews
    init(symbol: String, displayName: String, shortName: String, currentPrice: Double, previousClose: Double) {
        self.symbol = symbol
        self.displayName = displayName
        self.shortName = shortName
        self.currentPrice = currentPrice
        self.previousClose = previousClose
    }
}
