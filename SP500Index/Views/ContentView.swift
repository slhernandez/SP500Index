//
//  ContentView.swift
//  SP500Index
//
//  Main container view
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = StockViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Quote header
                QuoteHeaderView(
                    quote: viewModel.currentQuote,
                    lastUpdated: viewModel.lastUpdated,
                    isRefreshing: viewModel.isRefreshing
                )

                Divider()

                // Time range selector
                TimeRangeSelectorView(
                    selectedRange: $viewModel.selectedTimeRange,
                    onRangeChange: { range in
                        await viewModel.changeTimeRange(range)
                    }
                )

                // Chart - takes remaining space
                ChartView(
                    historicalData: viewModel.historicalData,
                    timeRange: viewModel.selectedTimeRange
                )
                .clipped()
                .frame(minHeight: 200)

                // Stats grid
                StatsGridView(quote: viewModel.currentQuote)

                // News feed
                NewsFeedView(articles: viewModel.newsArticles)
            }
            .padding(20)
        }
        .frame(minWidth: 400, minHeight: 750)
        .background(Color(NSColor.windowBackgroundColor))
        .overlay {
            // Loading overlay
            if viewModel.isLoading {
                LoadingOverlay()
            }

            // Error overlay
            if let error = viewModel.errorMessage {
                ErrorOverlay(message: error) {
                    Task {
                        await viewModel.loadInitialData()
                    }
                }
            }
        }
        .task {
            await viewModel.loadInitialData()
        }
        .onDisappear {
            viewModel.stopAutoRefresh()
        }
    }
}

// MARK: - Loading Overlay

struct LoadingOverlay: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.1)

            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)

                Text("Loading...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(24)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
    }
}

// MARK: - Error Overlay

struct ErrorOverlay: View {
    let message: String
    let retryAction: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)

            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)

                Text("Unable to Load Data")
                    .font(.headline)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)

                Button("Try Again") {
                    retryAction()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(32)
            .background(.ultraThickMaterial)
            .cornerRadius(16)
            .shadow(radius: 10)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .frame(width: 500, height: 700)
}
