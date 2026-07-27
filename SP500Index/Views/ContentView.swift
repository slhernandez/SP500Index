//
//  ContentView.swift
//  SP500Index
//
//  Main container view
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = StockViewModel()
    #if os(iOS)
    @State private var showSettings = false
    #endif

    var body: some View {
        #if os(iOS)
        NavigationStack {
            mainContent
                .navigationTitle(viewModel.currentQuote?.symbol ?? "S&P 500")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gear")
                        }
                    }
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }
        }
        .background(PlatformSupport.systemBackground.ignoresSafeArea())
        #else
        mainContent
        #endif
    }

    private var mainContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Market indices overview bar
                MarketIndicesBarView(
                    indexQuotes: viewModel.indexQuotes,
                    selectedCategory: viewModel.currentCategory,
                    isLoading: viewModel.isLoadingIndices,
                    onCategoryChange: { category in
                        await viewModel.changeMarketCategory(category)
                    },
                    onIndexTap: { symbol in
                        await viewModel.viewSymbolTemporarily(symbol)
                    }
                )

                // Return to primary banner (only when viewing non-primary)
                if viewModel.isViewingNonPrimary {
                    ReturnToPrimaryBanner(
                        primarySymbol: viewModel.selectedSymbol
                    ) {
                        await viewModel.returnToPrimarySymbol()
                    }
                }

                // Quote header
                QuoteHeaderView(
                    quote: viewModel.currentQuote,
                    lastUpdated: viewModel.lastUpdated,
                    isRefreshing: viewModel.isRefreshing,
                    investedAmount: viewModel.isViewingNonPrimary ? 0 : viewModel.investedAmount
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
                    quote: viewModel.currentQuote,
                    timeRange: viewModel.selectedTimeRange,
                    investedAmount: viewModel.isViewingNonPrimary ? 0 : viewModel.investedAmount
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
        .scrollIndicators(.hidden)
        #if os(iOS)
        .refreshable {
            await viewModel.manualRefresh()
        }
        #endif
        #if os(macOS)
        .frame(minWidth: 400, minHeight: 750)
        .onKeyPress(.escape) {
            if viewModel.isViewingNonPrimary {
                Task {
                    await viewModel.returnToPrimarySymbol()
                }
                return .handled
            }
            return .ignored
        }
        #endif
        .background(PlatformSupport.systemBackground.ignoresSafeArea())
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
        #if os(macOS)
        .onReceive(NotificationCenter.default.publisher(for: .manualRefreshRequested)) { _ in
            Task {
                await viewModel.manualRefresh()
            }
        }
        #endif
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
