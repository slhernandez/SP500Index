//
//  ChartView.swift
//  SP500Index
//
//  Interactive price chart using Swift Charts
//

import SwiftUI
import Charts

struct ChartView: View {
    let historicalData: HistoricalData?
    let timeRange: TimeRange
    @State private var selectedDataPoint: HistoricalDataPoint?
    @State private var plotWidth: CGFloat = 0

    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Selected point info or period summary
            if let selected = selectedDataPoint {
                SelectedPointView(dataPoint: selected, timeRange: timeRange)
            } else if let data = historicalData {
                PeriodSummaryView(data: data)
            }

            // Chart
            chartContent
                .frame(minHeight: 200)
                .animation(reduceMotion ? nil : .easeInOut(duration: 0.3), value: historicalData?.dataPoints.count)
        }
    }

    @ViewBuilder
    private var chartContent: some View {
        if let data = historicalData, !data.dataPoints.isEmpty {
            Chart {
                // Area fill under the line
                ForEach(data.dataPoints) { point in
                    AreaMark(
                        x: .value("Date", point.date),
                        y: .value("Price", point.close)
                    )
                    .foregroundStyle(areaGradient)
                    .interpolationMethod(.catmullRom)
                }

                // Line
                ForEach(data.dataPoints) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Price", point.close)
                    )
                    .foregroundStyle(lineColor)
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }

                // Selection indicator
                if let selected = selectedDataPoint {
                    RuleMark(x: .value("Date", selected.date))
                        .foregroundStyle(Color.secondary.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))

                    PointMark(
                        x: .value("Date", selected.date),
                        y: .value("Price", selected.close)
                    )
                    .foregroundStyle(lineColor)
                    .symbolSize(100)
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 5)) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(DateFormatters.formatForTimeRange(date, range: timeRange))
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .trailing, values: .automatic(desiredCount: 5)) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let price = value.as(Double.self) {
                            Text(NumberFormatters.formatCompactCurrency(price))
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartYScale(domain: chartYDomain(for: data))
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    handleChartInteraction(at: value.location, proxy: proxy, geometry: geometry, data: data)
                                }
                                .onEnded { _ in
                                    selectedDataPoint = nil
                                }
                        )
                        .onContinuousHover { phase in
                            switch phase {
                            case .active(let location):
                                handleChartInteraction(at: location, proxy: proxy, geometry: geometry, data: data)
                            case .ended:
                                selectedDataPoint = nil
                            }
                        }
                }
            }
        } else {
            // Empty state
            ContentUnavailableView {
                Label("No Data", systemImage: "chart.line.downtrend.xyaxis")
            } description: {
                Text("Historical data is not available")
            }
        }
    }

    // MARK: - Helpers

    private var lineColor: Color {
        guard let data = historicalData else { return .blue }
        return data.isPositivePeriod ? .stockGreen : .stockRed
    }

    private var areaGradient: LinearGradient {
        LinearGradient(
            colors: [lineColor.opacity(0.3), lineColor.opacity(0.0)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func chartYDomain(for data: HistoricalData) -> ClosedRange<Double> {
        let padding = data.priceRange * 0.1
        return (data.minPrice - padding)...(data.maxPrice + padding)
    }

    private func handleChartInteraction(at location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy, data: HistoricalData) {
        let xPosition = location.x - geometry[proxy.plotFrame!].origin.x

        guard let date: Date = proxy.value(atX: xPosition) else { return }

        // Find closest data point
        let closestPoint = data.dataPoints.min { point1, point2 in
            abs(point1.date.timeIntervalSince(date)) < abs(point2.date.timeIntervalSince(date))
        }

        selectedDataPoint = closestPoint
    }
}

// MARK: - Selected Point View

struct SelectedPointView: View {
    let dataPoint: HistoricalDataPoint
    let timeRange: TimeRange

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(dataPoint.close.asCurrency)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text(DateFormatters.formatForTimeRange(dataPoint.date, range: timeRange))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if let high = dataPoint.high, let low = dataPoint.low {
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Text("H:")
                            .foregroundColor(.secondary)
                        Text(high.asCurrency)
                    }
                    .font(.caption)

                    HStack(spacing: 4) {
                        Text("L:")
                            .foregroundColor(.secondary)
                        Text(low.asCurrency)
                    }
                    .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Period Summary View

struct PeriodSummaryView: View {
    let data: HistoricalData

    var body: some View {
        HStack {
            if let change = data.periodChange, let percentChange = data.periodPercentChange {
                Text(data.timeRange.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Spacer()

                Text(NumberFormatters.formatChange(change))
                    .font(.subheadline)
                    .foregroundColor(data.isPositivePeriod ? .stockGreen : .stockRed)

                Text("(\(NumberFormatters.formatPercent(percentChange)))")
                    .font(.subheadline)
                    .foregroundColor(data.isPositivePeriod ? .stockGreen : .stockRed)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    let mockData = HistoricalData(
        symbol: "FXAIX",
        dataPoints: (0..<30).map { i in
            let basePrice = 185.0 + Double(i) * 0.5 + Double.random(in: -2...2)
            return HistoricalDataPoint(
                date: Calendar.current.date(byAdding: .day, value: -29 + i, to: Date())!,
                close: basePrice,
                open: basePrice - 0.5,
                high: basePrice + 1,
                low: basePrice - 1,
                volume: Int.random(in: 1000000...5000000)
            )
        },
        timeRange: .oneMonth,
        fetchedAt: Date()
    )

    return ChartView(historicalData: mockData, timeRange: .oneMonth)
        .padding()
        .frame(width: 500, height: 350)
}
