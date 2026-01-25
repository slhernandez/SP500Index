# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SP500Index is a macOS desktop application (SwiftUI) that displays current prices and historical charts for S&P 500 index funds. It tracks FXAIX (Fidelity 500 Index Fund) by default, with support for SPY, VOO, and IVV.

**Requirements:** macOS 14.0+ (Sonoma), Xcode 15.0+, Swift 5.0

## Build Commands

```bash
# Build
xcodebuild build -scheme SP500Index -configuration Debug

# Clean
xcodebuild clean -scheme SP500Index

# Build and run (opens the app)
xcodebuild build -scheme SP500Index -configuration Debug && open build/Debug/SP500Index.app
```

No external package dependencies - uses native Apple frameworks only (SwiftUI, Charts, Combine).

## Architecture

**Pattern:** MVVM with actor-based concurrency

```
SP500Index/
├── App/                  # @main entry point, app delegate
├── Models/               # Data structures (StockQuote, HistoricalData, TimeRange)
├── ViewModels/           # StockViewModel - main state management
├── Views/                # SwiftUI components (ContentView, ChartView, etc.)
├── Services/             # StockDataService (actor), RefreshManager
└── Utilities/            # Date/Number formatters
```

**Key architectural decisions:**
- `StockDataService` is an **actor** for thread-safe Yahoo Finance API calls
- `StockViewModel` uses `@MainActor` for UI thread safety
- User preferences stored via `@AppStorage` (refresh interval, selected symbol)
- 5-minute cache for historical data to reduce API calls

## Data Flow

1. `StockViewModel` coordinates data fetching and UI state
2. `StockDataService` (actor) makes async calls to Yahoo Finance API (`query1.finance.yahoo.com`)
3. `RefreshManager` handles auto-refresh timer (configurable: 1, 5, 20, 60 minutes)
4. Views observe `@Published` properties on the ViewModel

## Key Files

- `Services/StockDataService.swift` - Yahoo Finance API client, handles market state detection (regular, pre-market, post-market, closed)
- `ViewModels/StockViewModel.swift` - Central state management, coordinates refresh and data loading
- `Models/TimeRange.swift` - Defines 9 time periods (1W to 10Y) with Yahoo API parameter mappings
- `Views/ChartView.swift` - Interactive chart with drag/hover gestures using SwiftUI Charts

## Important Notes

**Data Source:** Yahoo Finance unofficial API (no API key required). FXAIX (mutual fund) updates once daily at market close; ETFs (SPY, VOO, IVV) update throughout trading hours.

**UI Colors:**
- Stock green: `Color(red: 0.2, green: 0.78, blue: 0.35)`
- Stock red: `Color(red: 1.0, green: 0.27, blue: 0.23)`

**Window:** Min 400x500, default 500x600

**Future enhancements not yet implemented:** Menu bar widget, price alerts, portfolio tracking, unit tests
