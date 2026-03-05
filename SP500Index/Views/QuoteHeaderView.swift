//
//  QuoteHeaderView.swift
//  SP500Index
//
//  Price display header view
//

import SwiftUI

struct QuoteHeaderView: View {
    let quote: StockQuote?
    let lastUpdated: Date?
    let isRefreshing: Bool
    var investedAmount: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Fund name and symbol
            HStack {
                Text(fundDisplayName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Spacer()

                if isRefreshing {
                    ProgressView()
                        .scaleEffect(0.7)
                        .frame(width: 16, height: 16)
                }
            }

            // Current price
            Text(currentPriceText)
                .font(.system(size: 48, weight: .medium, design: .default))
                .foregroundColor(.primary)
                .minimumScaleFactor(0.8)
                .contentTransition(.numericText())

            // Change values
            HStack(spacing: 12) {
                // Dollar change
                Text(changeText)
                    .font(.title3)
                    .foregroundColor(changeColor)

                // Percent change
                Text(percentChangeText)
                    .font(.title3)
                    .foregroundColor(changeColor)

                // Market state badge
                if let quote = quote {
                    MarketStateBadge(state: quote.marketState)
                }
            }

            // Investment gain/loss
            if investedAmount > 0, let quote = quote {
                let gainLoss = investedAmount * (quote.percentChange / 100)
                let currentValue = investedAmount + gainLoss
                HStack(spacing: 4) {
                    Text("\(NumberFormatters.formatCurrency(investedAmount)) invested \u{2192} \(NumberFormatters.formatCurrency(currentValue))")
                        .foregroundColor(.secondary)
                    Text("(\(NumberFormatters.formatChange(gainLoss)) / \(NumberFormatters.formatPercent(quote.percentChange)))")
                        .foregroundColor(quote.isPositive ? .stockGreen : .stockRed)
                }
                .font(.subheadline)
            }

            // Last updated timestamp
            if let lastUpdated = lastUpdated {
                Text("Last updated: \(lastUpdated.asLastUpdated)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: quote?.currentPrice)
    }

    // MARK: - Computed Properties

    private var fundDisplayName: String {
        guard let quote = quote else {
            return "FXAIX - Fidelity 500 Index Fund"
        }
        return "\(quote.symbol) - \(quote.name)"
    }

    private var currentPriceText: String {
        guard let quote = quote else {
            return "$---.--"
        }
        return quote.currentPrice.asCurrency
    }

    private var changeText: String {
        guard let quote = quote else {
            return "+$0.00"
        }
        return quote.priceChange.asChange
    }

    private var percentChangeText: String {
        guard let quote = quote else {
            return "(+0.00%)"
        }
        return "(\(quote.percentChange.asPercent))"
    }

    private var changeColor: Color {
        guard let quote = quote else {
            return .secondary
        }
        return quote.isPositive ? .stockGreen : .stockRed
    }
}

// MARK: - Market State Badge

struct MarketStateBadge: View {
    let state: MarketState

    var body: some View {
        Text(state.displayText)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor.opacity(0.2))
            .foregroundColor(backgroundColor)
            .cornerRadius(4)
    }

    private var backgroundColor: Color {
        switch state {
        case .regular:
            return .green
        case .preMarket, .postMarket:
            return .orange
        case .closed:
            return .secondary
        }
    }
}

// MARK: - Color Extensions

extension Color {
    static let stockGreen = Color(red: 0.2, green: 0.78, blue: 0.35)
    static let stockRed = Color(red: 1.0, green: 0.27, blue: 0.23)
}

// MARK: - Preview

#Preview {
    VStack {
        QuoteHeaderView(
            quote: StockQuote(
                symbol: "FXAIX",
                name: "Fidelity 500 Index Fund",
                currentPrice: 198.45,
                previousClose: 196.14,
                currency: "USD",
                marketState: .closed,
                lastUpdated: Date(),
                open: 196.50,
                dayHigh: 199.00,
                dayLow: 195.80,
                volume: 2500000,
                fiftyTwoWeekHigh: 210.00,
                fiftyTwoWeekLow: 165.00,
                peRatio: nil,
                marketCap: nil,
                dividendYield: nil,
                beta: nil,
                eps: nil,
                avgVolume: nil
            ),
            lastUpdated: Date(),
            isRefreshing: false
        )

        Divider()
            .padding(.vertical)

        QuoteHeaderView(
            quote: StockQuote(
                symbol: "FXAIX",
                name: "Fidelity 500 Index Fund",
                currentPrice: 194.20,
                previousClose: 196.14,
                currency: "USD",
                marketState: .regular,
                lastUpdated: Date(),
                open: 196.50,
                dayHigh: 199.00,
                dayLow: 195.80,
                volume: 2500000,
                fiftyTwoWeekHigh: 210.00,
                fiftyTwoWeekLow: 165.00,
                peRatio: nil,
                marketCap: nil,
                dividendYield: nil,
                beta: nil,
                eps: nil,
                avgVolume: nil
            ),
            lastUpdated: Date(),
            isRefreshing: true
        )
    }
    .padding()
    .frame(width: 450)
}
