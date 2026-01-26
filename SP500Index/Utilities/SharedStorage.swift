//
//  SharedStorage.swift
//  SP500Index
//
//  Shared UserDefaults storage for main app and widget
//

import Foundation

/// Shared storage manager using App Group for main app and widget communication
struct SharedStorage {
    static let appGroupIdentifier = "group.com.steveh.SP500Index"

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }

    // MARK: - Keys

    private enum Keys {
        static let selectedSymbol = "widget.selectedSymbol"
        static let currentQuote = "widget.currentQuote"
        static let historicalData = "widget.historicalData"
        static let lastUpdated = "widget.lastUpdated"
    }

    // MARK: - Symbol

    static var selectedSymbol: String {
        get {
            sharedDefaults?.string(forKey: Keys.selectedSymbol) ?? "FXAIX"
        }
        set {
            sharedDefaults?.set(newValue, forKey: Keys.selectedSymbol)
        }
    }

    // MARK: - Quote

    static func saveQuote(_ quote: StockQuote) {
        guard let defaults = sharedDefaults else { return }
        if let data = try? JSONEncoder().encode(quote) {
            defaults.set(data, forKey: Keys.currentQuote)
            defaults.set(Date(), forKey: Keys.lastUpdated)
        }
    }

    static func loadQuote() -> StockQuote? {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: Keys.currentQuote) else { return nil }
        return try? JSONDecoder().decode(StockQuote.self, from: data)
    }

    // MARK: - Historical Data

    static func saveHistoricalData(_ data: HistoricalData) {
        guard let defaults = sharedDefaults else { return }
        if let encoded = try? JSONEncoder().encode(data) {
            defaults.set(encoded, forKey: Keys.historicalData)
        }
    }

    static func loadHistoricalData() -> HistoricalData? {
        guard let defaults = sharedDefaults,
              let data = defaults.data(forKey: Keys.historicalData) else { return nil }
        return try? JSONDecoder().decode(HistoricalData.self, from: data)
    }

    // MARK: - Last Updated

    static var lastUpdated: Date? {
        sharedDefaults?.object(forKey: Keys.lastUpdated) as? Date
    }
}
