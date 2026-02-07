//
//  MarketIndicesBarView.swift
//  SP500Index
//
//  Horizontal bar showing market indices with category selection
//

import SwiftUI

struct MarketIndicesBarView: View {
    let indexQuotes: [IndexQuote]
    let selectedCategory: MarketCategory
    let isLoading: Bool
    let onCategoryChange: (String) async -> Void
    let onIndexTap: (String) async -> Void

    #if os(iOS)
    @Environment(\.horizontalSizeClass) var sizeClass
    #endif

    private var useShortNames: Bool {
        #if os(iOS)
        return sizeClass == .compact
        #else
        return false
        #endif
    }

    private var useCompactLayout: Bool {
        #if os(iOS)
        return sizeClass == .compact
        #else
        return false
        #endif
    }

    var body: some View {
        HStack(spacing: 12) {
            // Category dropdown
            CategoryDropdown(
                selectedCategory: selectedCategory,
                onCategoryChange: onCategoryChange
            )

            // Index chips
            if isLoading {
                ForEach(0..<3, id: \.self) { _ in
                    IndexChipPlaceholder(useCompactLayout: useCompactLayout)
                }
            } else if indexQuotes.isEmpty {
                Text("Unable to load indices")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                ForEach(indexQuotes) { quote in
                    IndexChip(
                        quote: quote,
                        useShortName: useShortNames,
                        useCompactLayout: useCompactLayout
                    ) {
                        Task {
                            await onIndexTap(quote.symbol)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}

// MARK: - Category Dropdown

struct CategoryDropdown: View {
    let selectedCategory: MarketCategory
    let onCategoryChange: (String) async -> Void

    var body: some View {
        Menu {
            ForEach(MarketCategory.allCases) { category in
                Button {
                    Task {
                        await onCategoryChange(category.rawValue)
                    }
                } label: {
                    HStack {
                        Text(category.displayName)
                        if category == selectedCategory {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(selectedCategory.displayName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.secondary.opacity(0.15))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Index Chip

struct IndexChip: View {
    let quote: IndexQuote
    let useShortName: Bool
    var useCompactLayout: Bool = false
    let onTap: () -> Void

    private var stockGreen: Color {
        Color(red: 0.2, green: 0.78, blue: 0.35)
    }

    private var stockRed: Color {
        Color(red: 1.0, green: 0.27, blue: 0.23)
    }

    var body: some View {
        Button(action: onTap) {
            if useCompactLayout {
                compactContent
            } else {
                horizontalContent
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(quote.displayName), \(formatPrice(quote.currentPrice)), \(quote.isPositive ? "up" : "down") \(formatPercent(quote.percentChange))")
    }

    private var horizontalContent: some View {
        HStack(spacing: 6) {
            Text(useShortName ? quote.shortName : quote.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)

            Text(formatPrice(quote.currentPrice))
                .font(.caption)
                .lineLimit(1)

            HStack(spacing: 2) {
                Image(systemName: quote.isPositive ? "arrow.up" : "arrow.down")
                    .font(.caption2)
                Text(formatPercent(quote.percentChange))
                    .font(.caption)
            }
            .foregroundColor(quote.isPositive ? stockGreen : stockRed)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.secondary.opacity(0.1))
        )
    }

    private var compactContent: some View {
        VStack(spacing: 2) {
            Text(quote.shortName)
                .font(.caption)
                .fontWeight(.semibold)

            Text(formatCompactPrice(quote.currentPrice))
                .font(.caption)

            HStack(spacing: 2) {
                Image(systemName: quote.isPositive ? "arrow.up" : "arrow.down")
                    .font(.caption2)
                Text(formatPercent(quote.percentChange))
                    .font(.caption2)
            }
            .foregroundColor(quote.isPositive ? stockGreen : stockRed)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.secondary.opacity(0.1))
        )
    }

    private func formatPrice(_ price: Double) -> String {
        if price >= 1000 {
            return String(format: "%.2f", price)
        } else if price >= 1 {
            return String(format: "%.2f", price)
        } else {
            return String(format: "%.4f", price)
        }
    }

    private func formatCompactPrice(_ price: Double) -> String {
        if price >= 1000 {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 0
            return formatter.string(from: NSNumber(value: price)) ?? String(format: "%.0f", price)
        } else if price >= 1 {
            return String(format: "%.2f", price)
        } else {
            return String(format: "%.4f", price)
        }
    }

    private func formatPercent(_ percent: Double) -> String {
        String(format: "%.2f%%", abs(percent))
    }
}

// MARK: - Placeholder

struct IndexChipPlaceholder: View {
    var useCompactLayout: Bool = false

    var body: some View {
        if useCompactLayout {
            VStack(spacing: 2) {
                Text("IDX")
                    .font(.caption)
                    .fontWeight(.semibold)
                Text("0,000")
                    .font(.caption)
                Text("0.00%")
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.secondary.opacity(0.1))
            )
            .redacted(reason: .placeholder)
        } else {
            HStack(spacing: 6) {
                Text("Loading")
                    .font(.caption)
                Text("---.--")
                    .font(.caption)
                Text("--.--")
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.secondary.opacity(0.1))
            )
            .redacted(reason: .placeholder)
        }
    }
}

// MARK: - Return to Primary Banner

struct ReturnToPrimaryBanner: View {
    let primarySymbol: String
    let onReturn: () async -> Void

    var body: some View {
        Button {
            Task {
                await onReturn()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "house.fill")
                    .font(.caption)
                Text("Return to \(primarySymbol)")
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.accentColor.opacity(0.15))
            )
            .foregroundColor(.accentColor)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        MarketIndicesBarView(
            indexQuotes: [
                IndexQuote(symbol: "^DJI", displayName: "Dow Jones", shortName: "DJI", currentPrice: 48892.47, previousClose: 49068.12),
                IndexQuote(symbol: "^GSPC", displayName: "S&P 500", shortName: "SPX", currentPrice: 6040.53, previousClose: 6012.28),
                IndexQuote(symbol: "^IXIC", displayName: "Nasdaq", shortName: "NDX", currentPrice: 19681.75, previousClose: 19543.21)
            ],
            selectedCategory: .us,
            isLoading: false,
            onCategoryChange: { _ in },
            onIndexTap: { _ in }
        )

        MarketIndicesBarView(
            indexQuotes: [],
            selectedCategory: .us,
            isLoading: true,
            onCategoryChange: { _ in },
            onIndexTap: { _ in }
        )

        ReturnToPrimaryBanner(primarySymbol: "^GSPC") { }
    }
    .padding()
    .frame(width: 500)
}
