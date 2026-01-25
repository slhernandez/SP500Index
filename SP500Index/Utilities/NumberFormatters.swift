//
//  NumberFormatters.swift
//  SP500Index
//
//  Currency and percentage formatting utilities
//

import Foundation

struct NumberFormatters {
    // MARK: - Currency Formatters

    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    static let compactCurrencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    // MARK: - Percentage Formatters

    static let percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.multiplier = 1 // Already in percentage form
        return formatter
    }()

    // MARK: - Decimal Formatters

    static let decimalFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    // MARK: - Formatting Methods

    static func formatCurrency(_ value: Double) -> String {
        currencyFormatter.string(from: NSNumber(value: value)) ?? "$0.00"
    }

    static func formatCompactCurrency(_ value: Double) -> String {
        compactCurrencyFormatter.string(from: NSNumber(value: value)) ?? "$0"
    }

    static func formatChange(_ value: Double, includeSign: Bool = true) -> String {
        let sign = includeSign && value >= 0 ? "+" : ""
        return "\(sign)\(formatCurrency(value))"
    }

    static func formatPercent(_ value: Double, includeSign: Bool = true) -> String {
        let sign = includeSign && value >= 0 ? "+" : ""
        let formatted = String(format: "%.2f", value)
        return "\(sign)\(formatted)%"
    }

    static func formatDecimal(_ value: Double) -> String {
        decimalFormatter.string(from: NSNumber(value: value)) ?? "0.00"
    }

    static func formatVolume(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal

        if value >= 1_000_000_000 {
            return String(format: "%.2fB", Double(value) / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "%.2fM", Double(value) / 1_000_000)
        } else if value >= 1_000 {
            return String(format: "%.1fK", Double(value) / 1_000)
        } else {
            return formatter.string(from: NSNumber(value: value)) ?? "0"
        }
    }
}

// MARK: - Convenience Extensions

extension Double {
    var asCurrency: String {
        NumberFormatters.formatCurrency(self)
    }

    var asChange: String {
        NumberFormatters.formatChange(self)
    }

    var asPercent: String {
        NumberFormatters.formatPercent(self)
    }
}
