//
//  StockDataService.swift
//  SP500Index
//
//  API communication layer for fetching stock data
//

import Foundation

protocol StockDataServiceProtocol {
    func fetchQuote(symbol: String) async throws -> StockQuote
    func fetchHistoricalData(symbol: String, range: TimeRange) async throws -> HistoricalData
    func fetchNews(query: String) async throws -> [NewsArticle]
}

actor StockDataService: StockDataServiceProtocol {
    private let session: URLSession
    private let baseURL = "https://query1.finance.yahoo.com/v8/finance/chart"

    private var cachedHistoricalData: [String: HistoricalData] = [:]
    private let cacheTimeout: TimeInterval = 300 // 5 minutes

    private var cachedNews: [String: (articles: [NewsArticle], fetchedAt: Date)] = [:]
    private let newsCacheTimeout: TimeInterval = 900 // 15 minutes

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchQuote(symbol: String) async throws -> StockQuote {
        let url = buildURL(symbol: symbol, range: "1d", interval: "1d")
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw StockDataError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw StockDataError.httpError(statusCode: httpResponse.statusCode)
        }

        let chartResponse = try JSONDecoder().decode(YahooChartResponse.self, from: data)

        guard let result = chartResponse.chart.result?.first else {
            if let error = chartResponse.chart.error {
                throw StockDataError.apiError(message: error.description)
            }
            throw StockDataError.noData
        }

        return parseQuote(from: result, symbol: symbol)
    }

    func fetchHistoricalData(symbol: String, range: TimeRange) async throws -> HistoricalData {
        let cacheKey = "\(symbol)_\(range.rawValue)"

        // Check cache
        if let cached = cachedHistoricalData[cacheKey],
           Date().timeIntervalSince(cached.fetchedAt) < cacheTimeout {
            return cached
        }

        let url = buildURL(symbol: symbol, range: range.apiRange, interval: range.apiInterval)
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw StockDataError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw StockDataError.httpError(statusCode: httpResponse.statusCode)
        }

        let chartResponse = try JSONDecoder().decode(YahooChartResponse.self, from: data)

        guard let result = chartResponse.chart.result?.first else {
            if let error = chartResponse.chart.error {
                throw StockDataError.apiError(message: error.description)
            }
            throw StockDataError.noData
        }

        let historicalData = parseHistoricalData(from: result, symbol: symbol, range: range)

        // Cache the result
        cachedHistoricalData[cacheKey] = historicalData

        return historicalData
    }

    func clearCache() {
        cachedHistoricalData.removeAll()
        cachedNews.removeAll()
    }

    #if !WIDGET_EXTENSION
    func fetchIndexQuotes(for category: MarketCategory) async throws -> [IndexQuote] {
        let indices = category.indices

        return try await withThrowingTaskGroup(of: (Int, IndexQuote?).self) { group in
            for (index, marketIndex) in indices.enumerated() {
                group.addTask {
                    do {
                        let quote = try await self.fetchQuote(symbol: marketIndex.symbol)
                        return (index, IndexQuote(from: quote, index: marketIndex))
                    } catch {
                        // Graceful partial failure - return nil for failed fetches
                        return (index, nil)
                    }
                }
            }

            var results = [(Int, IndexQuote?)]()
            for try await result in group {
                results.append(result)
            }

            // Sort by original index and filter out failures
            return results.sorted { $0.0 < $1.0 }.compactMap { $0.1 }
        }
    }
    #endif

    func fetchNews(query: String) async throws -> [NewsArticle] {
        // Check cache
        if let cached = cachedNews[query],
           Date().timeIntervalSince(cached.fetchedAt) < newsCacheTimeout {
            return cached.articles
        }

        var components = URLComponents(string: "https://query1.finance.yahoo.com/v1/finance/search")!
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "newsCount", value: "8"),
            URLQueryItem(name: "quotesCount", value: "0")
        ]

        var request = URLRequest(url: components.url!)
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)", forHTTPHeaderField: "User-Agent")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw StockDataError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw StockDataError.httpError(statusCode: httpResponse.statusCode)
        }

        let searchResponse = try JSONDecoder().decode(YahooSearchResponse.self, from: data)
        let articles = searchResponse.news ?? []

        // Cache the result
        cachedNews[query] = (articles: articles, fetchedAt: Date())

        return articles
    }

    // MARK: - Private Methods

    private func buildURL(symbol: String, range: String, interval: String) -> URL {
        var components = URLComponents(string: "\(baseURL)/\(symbol)")!
        components.queryItems = [
            URLQueryItem(name: "range", value: range),
            URLQueryItem(name: "interval", value: interval),
            URLQueryItem(name: "includePrePost", value: "false"),
            URLQueryItem(name: "events", value: "div,splits")
        ]
        return components.url!
    }

    private func parseQuote(from result: YahooChartResult, symbol: String) -> StockQuote {
        let meta = result.meta

        let marketState = determineMarketState(from: meta)

        let fundName: String
        switch symbol.uppercased() {
        case "^GSPC":
            fundName = "S&P 500 Index"
        case "FXAIX":
            fundName = "Fidelity 500 Index Fund"
        case "SPY":
            fundName = "SPDR S&P 500 ETF"
        case "VOO":
            fundName = "Vanguard S&P 500 ETF"
        case "IVV":
            fundName = "iShares Core S&P 500 ETF"
        default:
            fundName = symbol
        }

        // Get open price from indicators if available
        let openPrice = result.indicators.quote.first?.open?.first ?? nil

        return StockQuote(
            symbol: meta.symbol,
            name: fundName,
            currentPrice: meta.regularMarketPrice,
            previousClose: meta.previousClose,
            currency: meta.currency,
            marketState: marketState,
            lastUpdated: Date(timeIntervalSince1970: TimeInterval(meta.regularMarketTime)),
            open: openPrice,
            dayHigh: meta.regularMarketDayHigh,
            dayLow: meta.regularMarketDayLow,
            volume: meta.regularMarketVolume,
            fiftyTwoWeekHigh: meta.fiftyTwoWeekHigh,
            fiftyTwoWeekLow: meta.fiftyTwoWeekLow,
            peRatio: nil,
            marketCap: nil,
            dividendYield: nil,
            beta: nil,
            eps: nil,
            avgVolume: nil
        )
    }

    private func determineMarketState(from meta: YahooMeta) -> MarketState {
        guard let tradingPeriod = meta.currentTradingPeriod else {
            return .closed
        }

        let now = Int(Date().timeIntervalSince1970)

        if let regular = tradingPeriod.regular,
           now >= regular.start && now < regular.end {
            return .regular
        }

        if let pre = tradingPeriod.pre,
           now >= pre.start && now < pre.end {
            return .preMarket
        }

        if let post = tradingPeriod.post,
           now >= post.start && now < post.end {
            return .postMarket
        }

        return .closed
    }

    private func parseHistoricalData(from result: YahooChartResult, symbol: String, range: TimeRange) -> HistoricalData {
        var dataPoints: [HistoricalDataPoint] = []

        guard let timestamps = result.timestamp,
              let quotes = result.indicators.quote.first,
              let closes = quotes.close else {
            return HistoricalData(symbol: symbol, dataPoints: [], timeRange: range, fetchedAt: Date())
        }

        let opens = quotes.open
        let highs = quotes.high
        let lows = quotes.low
        let volumes = quotes.volume

        for (index, timestamp) in timestamps.enumerated() {
            guard let closePrice = closes[safe: index] ?? nil else { continue }

            let dataPoint = HistoricalDataPoint(
                date: Date(timeIntervalSince1970: TimeInterval(timestamp)),
                close: closePrice,
                open: opens?[safe: index] ?? nil,
                high: highs?[safe: index] ?? nil,
                low: lows?[safe: index] ?? nil,
                volume: volumes?[safe: index] ?? nil
            )
            dataPoints.append(dataPoint)
        }

        return HistoricalData(
            symbol: symbol,
            dataPoints: dataPoints,
            timeRange: range,
            fetchedAt: Date()
        )
    }
}

// MARK: - Errors

enum StockDataError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case apiError(message: String)
    case noData
    case networkUnavailable

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .apiError(let message):
            return "API error: \(message)"
        case .noData:
            return "No data available"
        case .networkUnavailable:
            return "Network connection unavailable"
        }
    }
}

// MARK: - Array Safe Subscript

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
