//
//  StockViewModel.swift
//  SP500Index
//
//  Main view model for stock data management
//

import Foundation
import SwiftUI
import Combine

@MainActor
class StockViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var currentQuote: StockQuote?
    @Published var historicalData: HistoricalData?
    @Published var selectedTimeRange: TimeRange = .oneMonth
    @Published var isLoading: Bool = false
    @Published var isRefreshing: Bool = false
    @Published var errorMessage: String?
    @Published var lastUpdated: Date?

    // Settings
    @AppStorage("refreshInterval") var refreshIntervalMinutes: Int = 5
    @AppStorage("selectedSymbol") var selectedSymbol: String = "FXAIX"

    // MARK: - Private Properties

    private let dataService: StockDataService
    private let refreshManager = RefreshManager()
    private var cancellables = Set<AnyCancellable>()
    private var isChangingSymbol = false

    // MARK: - Computed Properties

    var fundDisplayName: String {
        guard let quote = currentQuote else {
            return "\(selectedSymbol) - S&P 500 Index"
        }
        return "\(quote.symbol) - \(quote.name)"
    }

    var isMarketOpen: Bool {
        currentQuote?.marketState == .regular
    }

    var marketStateText: String {
        currentQuote?.marketState.displayText ?? "Loading..."
    }

    // MARK: - Initialization

    init(dataService: StockDataService = StockDataService()) {
        self.dataService = dataService
        setupRefreshManager()
        observeSymbolChanges()
    }

    // MARK: - Symbol Change Handling

    func changeSymbol(_ newSymbol: String) async {
        guard !isChangingSymbol else { return }
        guard newSymbol != currentQuote?.symbol else { return }

        isChangingSymbol = true

        // Clear cache for fresh data
        await dataService.clearCache()

        // Reload all data for new symbol
        await loadInitialData()

        isChangingSymbol = false
    }

    private func observeSymbolChanges() {
        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                let storedSymbol = UserDefaults.standard.string(forKey: "selectedSymbol") ?? "FXAIX"
                let loadedSymbol = self.currentQuote?.symbol ?? ""

                if storedSymbol != loadedSymbol && !loadedSymbol.isEmpty {
                    Task {
                        await self.changeSymbol(storedSymbol)
                    }
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods

    func loadInitialData() async {
        isLoading = true
        errorMessage = nil

        do {
            async let quoteTask = dataService.fetchQuote(symbol: selectedSymbol)
            async let historicalTask = dataService.fetchHistoricalData(symbol: selectedSymbol, range: selectedTimeRange)

            let (quote, historical) = try await (quoteTask, historicalTask)

            currentQuote = quote
            historicalData = historical
            lastUpdated = Date()

            // Persist to shared storage for widget
            persistToSharedStorage(quote: quote, historicalData: historical)

            // Start auto-refresh after initial load
            refreshManager.start()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func refreshData() async {
        guard !isRefreshing else { return }

        isRefreshing = true
        errorMessage = nil

        do {
            let quote = try await dataService.fetchQuote(symbol: selectedSymbol)
            currentQuote = quote
            lastUpdated = Date()

            // Update widget with fresh quote
            SharedStorage.saveQuote(quote)
        } catch {
            errorMessage = error.localizedDescription
        }

        isRefreshing = false
    }

    func changeTimeRange(_ range: TimeRange) async {
        // Note: selectedTimeRange is already updated via binding from TimeRangeSelectorView
        isLoading = true
        errorMessage = nil

        do {
            let historical = try await dataService.fetchHistoricalData(symbol: selectedSymbol, range: range)
            historicalData = historical

            // Update widget with fresh historical data
            SharedStorage.saveHistoricalData(historical)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func manualRefresh() async {
        await refreshManager.triggerManualRefresh()
    }

    func updateRefreshInterval(_ minutes: Int) {
        refreshIntervalMinutes = minutes
        refreshManager.updateInterval(minutes)
    }

    func stopAutoRefresh() {
        refreshManager.stop()
    }

    func startAutoRefresh() {
        refreshManager.start()
    }

    // MARK: - Private Methods

    private func setupRefreshManager() {
        refreshManager.configure(intervalMinutes: refreshIntervalMinutes) { [weak self] in
            await self?.refreshData()
        }
    }

    private func persistToSharedStorage(quote: StockQuote, historicalData: HistoricalData) {
        SharedStorage.selectedSymbol = selectedSymbol
        SharedStorage.saveQuote(quote)
        SharedStorage.saveHistoricalData(historicalData)
    }
}

// MARK: - Preview Support

extension StockViewModel {
    static var preview: StockViewModel {
        let viewModel = StockViewModel()
        viewModel.currentQuote = StockQuote(
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
        )
        viewModel.historicalData = HistoricalData(
            symbol: "FXAIX",
            dataPoints: Self.generateMockDataPoints(),
            timeRange: .oneMonth,
            fetchedAt: Date()
        )
        return viewModel
    }

    private static func generateMockDataPoints() -> [HistoricalDataPoint] {
        let calendar = Calendar.current
        var dataPoints: [HistoricalDataPoint] = []
        var basePrice = 185.0

        for dayOffset in (0..<30).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: Date()) else { continue }

            // Add some realistic price movement
            let change = Double.random(in: -2.0...2.5)
            basePrice += change
            basePrice = max(basePrice, 170) // Floor

            dataPoints.append(HistoricalDataPoint(
                date: date,
                close: basePrice,
                open: basePrice - Double.random(in: -1...1),
                high: basePrice + Double.random(in: 0...2),
                low: basePrice - Double.random(in: 0...2),
                volume: Int.random(in: 1000000...5000000)
            ))
        }

        return dataPoints
    }
}
