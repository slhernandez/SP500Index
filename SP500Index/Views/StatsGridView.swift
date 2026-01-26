//
//  StatsGridView.swift
//  SP500Index
//
//  Stock statistics grid similar to Apple Stocks app
//

import SwiftUI

struct StatsGridView: View {
    let quote: StockQuote?

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Row 1: Open, Vol, 52W H, Yield
            HStack(spacing: 0) {
                StatCell(label: "Open", value: formatPrice(quote?.open))
                Divider().frame(height: 40)
                StatCell(label: "Vol", value: formatVolume(quote?.volume))
                Divider().frame(height: 40)
                StatCell(label: "52W H", value: formatPrice(quote?.fiftyTwoWeekHigh))
                Divider().frame(height: 40)
                StatCell(label: "Yield", value: formatPercent(quote?.dividendYield))
            }

            Divider()

            // Row 2: High, P/E, 52W L, Beta
            HStack(spacing: 0) {
                StatCell(label: "High", value: formatPrice(quote?.dayHigh))
                Divider().frame(height: 40)
                StatCell(label: "P/E", value: formatDecimal(quote?.peRatio))
                Divider().frame(height: 40)
                StatCell(label: "52W L", value: formatPrice(quote?.fiftyTwoWeekLow))
                Divider().frame(height: 40)
                StatCell(label: "Beta", value: formatDecimal(quote?.beta))
            }

            Divider()

            // Row 3: Low, Mkt Cap, Avg Vol, EPS
            HStack(spacing: 0) {
                StatCell(label: "Low", value: formatPrice(quote?.dayLow))
                Divider().frame(height: 40)
                StatCell(label: "Mkt Cap", value: formatMarketCap(quote?.marketCap))
                Divider().frame(height: 40)
                StatCell(label: "Avg Vol", value: formatVolume(quote?.avgVolume))
                Divider().frame(height: 40)
                StatCell(label: "EPS", value: formatDecimal(quote?.eps))
            }
        }
        .padding(.vertical, 8)
        .background(Color.secondary.opacity(0.05))
        .cornerRadius(8)
    }

    // MARK: - Formatters

    private func formatPrice(_ value: Double?) -> String {
        guard let value = value else { return "–" }
        return NumberFormatters.formatCurrency(value)
    }

    private func formatVolume(_ value: Int?) -> String {
        guard let value = value else { return "–" }
        return NumberFormatters.formatVolume(value)
    }

    private func formatPercent(_ value: Double?) -> String {
        guard let value = value else { return "–" }
        return String(format: "%.2f%%", value)
    }

    private func formatDecimal(_ value: Double?) -> String {
        guard let value = value else { return "–" }
        return String(format: "%.2f", value)
    }

    private func formatMarketCap(_ value: Double?) -> String {
        guard let value = value else { return "–" }
        if value >= 1_000_000_000_000 {
            return String(format: "%.2fT", value / 1_000_000_000_000)
        } else if value >= 1_000_000_000 {
            return String(format: "%.2fB", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "%.2fM", value / 1_000_000)
        } else {
            return NumberFormatters.formatCurrency(value)
        }
    }
}

// MARK: - Stat Cell

struct StatCell: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(value == "–" ? .secondary : .primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

// MARK: - Preview

#Preview {
    StatsGridView(quote: StockQuote(
        symbol: "FXAIX",
        name: "Fidelity 500 Index Fund",
        currentPrice: 240.33,
        previousClose: 238.50,
        currency: "USD",
        marketState: .closed,
        lastUpdated: Date(),
        open: 239.00,
        dayHigh: 241.50,
        dayLow: 238.00,
        volume: 2500000,
        fiftyTwoWeekHigh: 242.40,
        fiftyTwoWeekLow: 173.01,
        peRatio: nil,
        marketCap: nil,
        dividendYield: 1.11,
        beta: 1.00,
        eps: nil,
        avgVolume: nil
    ))
    .padding()
    .frame(width: 500)
}
