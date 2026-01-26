# SP500Index

A native macOS desktop application for tracking S&P 500 index fund prices and historical performance.

## Features

- **Real-time price tracking** for S&P 500 index funds (FXAIX, SPY, VOO, IVV)
- **Interactive historical charts** with 9 time ranges (1 week to 10 years)
- **Desktop widget** with three sizes for at-a-glance price monitoring
- **Auto-refresh** with configurable intervals (1, 5, 20, or 60 minutes)
- **Market state detection** (regular hours, pre-market, post-market, closed)
- **Native macOS experience** with keyboard shortcuts and settings window

## Requirements

- macOS 14.0+ (Sonoma)
- Xcode 15.0+ (for building)

## Installation

### Build from Source

```bash
git clone https://github.com/yourusername/SP500Index.git
cd SP500Index
xcodebuild build -scheme SP500Index -configuration Release
open build/Release/SP500Index.app
```

### Development

```bash
# Debug build
xcodebuild build -scheme SP500Index -configuration Debug

# Build and run
xcodebuild build -scheme SP500Index -configuration Debug && open build/Debug/SP500Index.app

# Clean build
xcodebuild clean -scheme SP500Index
```

Or open `SP500Index.xcodeproj` in Xcode.

## Usage

1. Launch the app to see the current price of FXAIX (Fidelity 500 Index Fund)
2. Use the time range buttons to view different historical periods
3. Hover over the chart to see specific data points
4. Press **Cmd+R** to manually refresh data
5. Open **Settings** (Cmd+,) to change the tracked symbol or refresh interval

### Supported Symbols

| Symbol | Fund Name |
|--------|-----------|
| FXAIX | Fidelity 500 Index Fund |
| SPY | SPDR S&P 500 ETF |
| VOO | Vanguard S&P 500 ETF |
| IVV | iShares Core S&P 500 ETF |

## Desktop Widget

The app includes a macOS desktop widget for monitoring prices at a glance without opening the main app.

### Adding the Widget

1. Right-click on your desktop and select "Edit Widgets..."
2. Search for "S&P 500" in the widget gallery
3. Drag your preferred widget size to the desktop

### Widget Sizes

| Size | Display |
|------|---------|
| **Small** | Symbol, price, daily change, market status |
| **Medium** | Price info + mini sparkline chart |
| **Large** | Full details with chart and stats (Open, High, Low, 52W Range) |

### How It Works

- The widget displays the same symbol selected in the main app
- Data is shared via App Groups between the app and widget
- Refreshes every 15 minutes during market hours, hourly otherwise
- Open the main app to update the widget with fresh data

## Architecture

Built with SwiftUI using the MVVM pattern and Swift's actor-based concurrency:

- **StockViewModel** - Central state management (`@MainActor`)
- **StockDataService** - Thread-safe API client (`actor`)
- **RefreshManager** - Handles auto-refresh scheduling

No external dependencies - uses only native Apple frameworks (SwiftUI, Charts, Combine).

## Data Source

Price data is provided by Yahoo Finance. Note that mutual funds (FXAIX) update once daily at market close, while ETFs (SPY, VOO, IVV) update throughout trading hours.

## License

MIT License - See [LICENSE](LICENSE) for details.
