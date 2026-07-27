//
//  WidgetViews.swift
//  SP500Widget
//
//  Widget views for small, medium, and large sizes
//

import SwiftUI
import WidgetKit
import Charts

// MARK: - Small Widget View

struct SmallWidgetView: View {
    let entry: StockEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Symbol and name
            Text(entry.symbol)
                .font(.headline)
                .fontWeight(.bold)

            Text(entry.name)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()

            // Price
            Text(formatCurrency(entry.price))
                .font(.title2)
                .fontWeight(.semibold)

            // Change
            HStack(spacing: 4) {
                Image(systemName: entry.isPositive ? "arrow.up.right" : "arrow.down.right")
                    .font(.caption)

                Text(formatChange(entry.priceChange))
                    .font(.caption)

                Text("(\(formatPercent(entry.percentChange)))")
                    .font(.caption)
            }
            .foregroundStyle(Color.stockColor(isPositive: entry.isPositive))

            // Market status
            Text(entry.marketState.displayText)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}

// MARK: - Medium Widget View

struct MediumWidgetView: View {
    let entry: StockEntry

    var body: some View {
        HStack(spacing: 16) {
            // Left side: Price info
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.symbol)
                    .font(.headline)
                    .fontWeight(.bold)

                Text(entry.name)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                Spacer()

                Text(formatCurrency(entry.price))
                    .font(.title)
                    .fontWeight(.semibold)

                HStack(spacing: 4) {
                    Image(systemName: entry.isPositive ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption)

                    Text(formatChange(entry.priceChange))
                        .font(.caption)

                    Text("(\(formatPercent(entry.percentChange)))")
                        .font(.caption)
                }
                .foregroundStyle(Color.stockColor(isPositive: entry.isPositive))

                Text(entry.marketState.displayText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Right side: Mini chart
            if let chartData = entry.historicalData, !chartData.isEmpty {
                MiniChartView(data: chartData, isPositive: entry.isPositive)
                    .frame(width: 120, height: 60)
            }
        }
        .padding()
    }
}

// MARK: - Large Widget View

struct LargeWidgetView: View {
    let entry: StockEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.symbol)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(entry.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatCurrency(entry.price))
                        .font(.title)
                        .fontWeight(.semibold)

                    HStack(spacing: 4) {
                        Image(systemName: entry.isPositive ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption)

                        Text("\(formatChange(entry.priceChange)) (\(formatPercent(entry.percentChange)))")
                            .font(.caption)
                    }
                    .foregroundStyle(Color.stockColor(isPositive: entry.isPositive))
                }
            }

            // Chart
            if let chartData = entry.historicalData, !chartData.isEmpty {
                ChartView(data: chartData, isPositive: entry.isPositive)
                    .frame(height: 100)
            }

            Divider()

            // Stats grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                if let open = entry.open {
                    StatRow(label: "Open", value: formatCurrency(open))
                }
                if let high = entry.dayHigh {
                    StatRow(label: "High", value: formatCurrency(high))
                }
                if let low = entry.dayLow {
                    StatRow(label: "Low", value: formatCurrency(low))
                }
                if let high52 = entry.fiftyTwoWeekHigh, let low52 = entry.fiftyTwoWeekLow {
                    StatRow(label: "52W Range", value: "\(formatCompactCurrency(low52)) - \(formatCompactCurrency(high52))")
                }
            }

            Spacer()

            // Footer
            HStack {
                Text(entry.marketState.displayText)
                    .font(.caption2)
                    .foregroundStyle(.secondary)

                Spacer()

                Text("Updated \(entry.date.asLastUpdated)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}

// MARK: - Supporting Views

struct StatRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

struct MiniChartView: View {
    let data: [StockEntry.ChartDataPoint]
    let isPositive: Bool

    private var yDomain: ClosedRange<Double> {
        WidgetChartScale.domain(for: data)
    }

    var body: some View {
        Chart(data) { point in
            LineMark(
                x: .value("Date", point.date),
                y: .value("Price", point.price)
            )
            .foregroundStyle(Color.stockColor(isPositive: isPositive))

            AreaMark(
                x: .value("Date", point.date),
                yStart: .value("Baseline", yDomain.lowerBound),
                yEnd: .value("Price", point.price)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.stockColor(isPositive: isPositive).opacity(0.3), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
        .chartYScale(domain: yDomain)
    }
}

struct ChartView: View {
    let data: [StockEntry.ChartDataPoint]
    let isPositive: Bool

    private var yDomain: ClosedRange<Double> {
        WidgetChartScale.domain(for: data)
    }

    var body: some View {
        Chart(data) { point in
            LineMark(
                x: .value("Date", point.date),
                y: .value("Price", point.price)
            )
            .foregroundStyle(Color.stockColor(isPositive: isPositive))
            .lineStyle(StrokeStyle(lineWidth: 2))

            AreaMark(
                x: .value("Date", point.date),
                yStart: .value("Baseline", yDomain.lowerBound),
                yEnd: .value("Price", point.price)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.stockColor(isPositive: isPositive).opacity(0.2), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month().day())
                    .font(.caption2)
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing, values: .automatic(desiredCount: 3)) { _ in
                AxisGridLine()
                AxisValueLabel()
                    .font(.caption2)
            }
        }
        .chartYScale(domain: yDomain)
    }
}

private enum WidgetChartScale {
    static func domain(for data: [StockEntry.ChartDataPoint]) -> ClosedRange<Double> {
        guard let minimum = data.map(\.price).min(),
              let maximum = data.map(\.price).max() else {
            return 0...1
        }

        let padding = max((maximum - minimum) * 0.1, max(abs(maximum) * 0.001, 0.01))
        return (minimum - padding)...(maximum + padding)
    }
}

// MARK: - Formatting Helpers

private func formatCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "USD"
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    return formatter.string(from: NSNumber(value: value)) ?? "$0.00"
}

private func formatCompactCurrency(_ value: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.currencyCode = "USD"
    formatter.minimumFractionDigits = 0
    formatter.maximumFractionDigits = 0
    return formatter.string(from: NSNumber(value: value)) ?? "$0"
}

private func formatChange(_ value: Double) -> String {
    let sign = value >= 0 ? "+" : ""
    return "\(sign)\(formatCurrency(value))"
}

private func formatPercent(_ value: Double) -> String {
    let sign = value >= 0 ? "+" : ""
    return "\(sign)\(String(format: "%.2f", value))%"
}

// MARK: - Previews

#Preview("Small") {
    SmallWidgetView(entry: .preview)
        .frame(width: 160, height: 160)
}

#Preview("Medium") {
    MediumWidgetView(entry: .preview)
        .frame(width: 338, height: 160)
}

#Preview("Large") {
    LargeWidgetView(entry: .preview)
        .frame(width: 338, height: 354)
}

// MARK: - Lock Screen Widgets (iOS only)

#if os(iOS)

/// Circular Lock Screen widget - shows price change indicator
struct AccessoryCircularView: View {
    let entry: StockEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()

            VStack(spacing: 0) {
                // Symbol
                Text(entry.symbol)
                    .font(.system(size: 10, weight: .semibold))
                    .minimumScaleFactor(0.8)

                // Change indicator
                Image(systemName: entry.isPositive ? "arrow.up" : "arrow.down")
                    .font(.system(size: 14, weight: .bold))

                // Percent change
                Text(formatPercentCompact(entry.percentChange))
                    .font(.system(size: 10, weight: .medium))
                    .minimumScaleFactor(0.8)
            }
        }
    }

    private func formatPercentCompact(_ value: Double) -> String {
        let prefix = value >= 0 ? "+" : ""
        return "\(prefix)\(String(format: "%.1f", value))%"
    }
}

/// Rectangular Lock Screen widget - shows price and change
struct AccessoryRectangularView: View {
    let entry: StockEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Symbol and name
            HStack {
                Text(entry.symbol)
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                // Change arrow
                Image(systemName: entry.isPositive ? "arrow.up.right" : "arrow.down.right")
                    .font(.caption)
                    .foregroundStyle(entry.isPositive ? .green : .red)
            }

            // Price
            Text(formatCurrencyCompact(entry.price))
                .font(.system(.body, design: .rounded))
                .fontWeight(.medium)

            // Change details
            HStack(spacing: 4) {
                Text(formatChangeCompact(entry.priceChange))
                Text("(\(formatPercentCompact(entry.percentChange)))")
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func formatCurrencyCompact(_ value: Double) -> String {
        return String(format: "$%.2f", value)
    }

    private func formatChangeCompact(_ value: Double) -> String {
        let prefix = value >= 0 ? "+" : ""
        return "\(prefix)\(String(format: "%.2f", value))"
    }

    private func formatPercentCompact(_ value: Double) -> String {
        let prefix = value >= 0 ? "+" : ""
        return "\(prefix)\(String(format: "%.2f", value))%"
    }
}

#endif
