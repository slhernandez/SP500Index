# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

SP500Index is a macOS, iPhone, and iPad application (SwiftUI) that displays current prices, historical charts, and market news for S&P 500 index funds. It tracks FXAIX (Fidelity 500 Index Fund) by default, with support for SPY, VOO, IVV, and ^GSPC (S&P 500 Index). Includes desktop and Home Screen/Lock Screen widgets for at-a-glance price monitoring.

**Requirements:** macOS 14.0+ (Sonoma) or iOS/iPadOS 17.0+, Xcode 15.0+, Swift 5.9+

## Build Commands

```bash
# Build (macOS)
xcodebuild build -scheme SP500Index -configuration Debug

# Build (iPhone Simulator)
xcodebuild build -scheme SP500Index -destination 'platform=iOS Simulator,name=iPhone 17'

# Clean
xcodebuild clean -scheme SP500Index

# Build and run (macOS)
xcodebuild build -scheme SP500Index -configuration Debug && open build/Debug/SP500Index.app

# Build signed + notarized DMG for distribution
./scripts/build-release.sh
```

No external package dependencies - uses native Apple frameworks only (SwiftUI, Charts, Combine, WidgetKit).

## Architecture

**Pattern:** MVVM with actor-based concurrency

```
SP500Index/
├── App/                  # @main entry point, app delegate
├── Models/               # StockQuote, HistoricalData, TimeRange, NewsArticle
├── ViewModels/           # StockViewModel - main state management
├── Views/                # ContentView, ChartView, NewsFeedView, etc.
├── Services/             # StockDataService (actor), RefreshManager
├── Utilities/            # Formatters, SharedStorage (App Groups)
└── Resources/

SP500Widget/              # Widget extension (desktop, Home Screen, Lock Screen)
├── SP500Widget.swift     # Widget entry point (@main)
├── TimelineProvider.swift# Timeline and refresh scheduling
├── StockEntry.swift      # Timeline entry model
├── WidgetViews.swift     # Small/Medium/Large + Lock Screen widget views
└── Colors.swift          # Widget color definitions

scripts/
└── build-release.sh      # Local signed + notarized DMG build

.github/workflows/
├── ci.yml                # CI for PRs and main branch
└── release.yml           # Release workflow (tag-triggered)
```

**Key architectural decisions:**
- `StockDataService` is an **actor** for thread-safe Yahoo Finance API calls
- `StockViewModel` uses `@MainActor` for UI thread safety
- User preferences stored via `@AppStorage` (refresh interval, selected symbol)
- 5-minute cache for historical data, 15-minute cache for news
- **App Groups** (`group.com.steveh.SP500Index`) for widget data sharing

## Data Flow

1. `StockViewModel` coordinates data fetching and UI state
2. `StockDataService` (actor) makes async calls to Yahoo Finance API
3. `RefreshManager` handles auto-refresh timer (configurable: 1, 5, 20, 60 minutes)
4. Views observe `@Published` properties on the ViewModel
5. Main app persists data to `SharedStorage` (App Groups UserDefaults)
6. Widget's `TimelineProvider` reads from shared storage
7. `WidgetCenter.shared.reloadTimelines()` triggers widget refresh after data updates

## Key Files

| File | Purpose |
|------|---------|
| `Services/StockDataService.swift` | Yahoo Finance API client (quotes, historical data, news), market state detection |
| `ViewModels/StockViewModel.swift` | Central state management, coordinates refresh and data loading |
| `Models/TimeRange.swift` | Defines 10 time periods (1D to 10Y) with Yahoo API parameter mappings |
| `Models/NewsArticle.swift` | News article model with relative time formatting |
| `Views/MarketIndicesBarView.swift` | Market indices bar with adaptive layout (compact cards on iPhone) |
| `Views/ChartView.swift` | Interactive chart with drag/hover gestures using SwiftUI Charts |
| `Views/NewsFeedView.swift` | 2-column news grid with clickable headlines |
| `Utilities/SharedStorage.swift` | App Groups storage for widget data sharing |
| `SP500Widget/TimelineProvider.swift` | Widget timeline and market-aware refresh scheduling |

## Yahoo Finance API Endpoints

```
# Price quotes and historical data
https://query1.finance.yahoo.com/v8/finance/chart/{SYMBOL}?range={range}&interval={interval}

# News search
https://query1.finance.yahoo.com/v1/finance/search?q=S%26P%20500&newsCount=8&quotesCount=0
```

No API key required. User-Agent header set to avoid blocking.

## Supported Symbols

| Symbol | Name | Update Frequency |
|--------|------|------------------|
| FXAIX | Fidelity 500 Index Fund | Once daily at market close |
| SPY | SPDR S&P 500 ETF | Throughout trading hours |
| VOO | Vanguard S&P 500 ETF | Throughout trading hours |
| IVV | iShares Core S&P 500 ETF | Throughout trading hours |
| ^GSPC | S&P 500 Index | Once daily at market close |

## Widgets

Five widget sizes supported across platforms:
- **Small** (macOS, iPhone, iPad): Symbol, price, daily change, market status
- **Medium** (macOS, iPhone, iPad): Price info + mini sparkline chart
- **Large** (macOS, iPhone, iPad): Full details with chart and stats
- **Circular** (iPhone, iPad Lock Screen): Symbol, arrow indicator, percent change
- **Rectangular** (iPhone, iPad Lock Screen): Symbol, price, change details

Widget refresh schedule:
- Market hours (9:30 AM - 4:00 PM ET): Every 15 minutes
- Outside market hours: Hourly

## Distribution

The app is signed with Developer ID and notarized by Apple.

### Local Build
```bash
# Prerequisites (one-time):
# 1. Developer ID Application certificate (Xcode → Settings → Accounts → Manage Certificates)
# 2. Store notarization credentials:
xcrun notarytool store-credentials "SP500Index-notarize" \
  --apple-id "your@email.com" \
  --team-id "YOUR_TEAM_ID" \
  --password "your-app-specific-password"

# Build signed + notarized DMG:
./scripts/build-release.sh
```

### GitHub Actions Release
```bash
# Push a version tag to trigger automated release
git tag v1.0.0
git push origin v1.0.0
```

**Required GitHub Secrets:**
| Secret | Description |
|--------|-------------|
| `BUILD_CERTIFICATE_BASE64` | Developer ID certificate (.p12), base64 encoded |
| `P12_PASSWORD` | Password for the .p12 file |
| `KEYCHAIN_PASSWORD` | Any random password (for temp CI keychain) |
| `APPLE_ID` | Apple Developer account email |
| `APPLE_APP_SPECIFIC_PASSWORD` | App-specific password for notarization |
| `APPLE_TEAM_ID` | 10-character Apple Team ID |
| `APP_PROVISIONING_PROFILE_BASE64` | Main app provisioning profile |
| `WIDGET_PROVISIONING_PROFILE_BASE64` | Widget provisioning profile |

## Important Notes

**UI Colors:**
- Stock green: `Color(red: 0.2, green: 0.78, blue: 0.35)`
- Stock red: `Color(red: 1.0, green: 0.27, blue: 0.23)`

**Window (macOS):** Min 400x750 (increased for news section)

**iPhone layout:** Uses `horizontalSizeClass == .compact` to switch to compact layouts (vertical market index cards, adapted spacing)

**Bundle ID:** `com.steveh.SP500Index`

**App Group:** `group.com.steveh.SP500Index`

## Future Enhancements (Not Yet Implemented)

- Menu bar widget (always-visible price)
- Price alerts with notifications
- Portfolio tracking with multiple positions
- Unit tests for ViewModel and Service layers
