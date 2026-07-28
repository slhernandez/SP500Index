//
//  SharedStorage.swift
//  SP500Index
//
//  Shared storage for main app and widget via App Group container
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
            sharedDefaults?.string(forKey: Keys.selectedSymbol) ?? "^GSPC"
        }
        set {
            sharedDefaults?.set(newValue, forKey: Keys.selectedSymbol)
            sharedDefaults?.synchronize()
        }
    }

    // MARK: - Quote

    static func saveQuote(_ quote: StockQuote) {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            return
        }

        let fileURL = containerURL.appendingPathComponent("quote.json")
        do {
            let data = try JSONEncoder().encode(quote)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            // Silently fail - widget will show stale data
        }
    }

    static func loadQuote() -> StockQuote? {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            return nil
        }

        let fileURL = containerURL.appendingPathComponent("quote.json")
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(StockQuote.self, from: data)
        } catch {
            return nil
        }
    }

    // MARK: - Historical Data

    static func saveHistoricalData(_ data: HistoricalData) {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            return
        }

        let fileURL = containerURL.appendingPathComponent("historical.json")
        do {
            let encoded = try JSONEncoder().encode(data)
            try encoded.write(to: fileURL, options: .atomic)
        } catch {
            // Silently fail - widget will show stale data
        }
    }

    static func saveWidgetData(
        quote: StockQuote,
        historicalData: HistoricalData,
        updatedAt: Date = Date()
    ) {
        saveQuote(quote)
        saveHistoricalData(historicalData)
        sharedDefaults?.set(updatedAt, forKey: Keys.lastUpdated)
        sharedDefaults?.synchronize()
    }

    static func loadHistoricalData() -> HistoricalData? {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupIdentifier) else {
            return nil
        }

        let fileURL = containerURL.appendingPathComponent("historical.json")
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(HistoricalData.self, from: data)
        } catch {
            return nil
        }
    }

    // MARK: - Last Updated

    static var lastUpdated: Date? {
        sharedDefaults?.object(forKey: Keys.lastUpdated) as? Date
    }
}
