# SP500Index

SP500Index is a native macOS, iPadOS, and iOS application built with SwiftUI for tracking S&P 500 index fund prices. It displays real-time quotes and interactive historical charts for popular index funds including FXAIX, VOO, SPY, and IVV. Features include desktop and Lock Screen widgets for at-a-glance price updates, configurable auto-refresh intervals, and support for multiple time ranges from 1 week to 10 years. Built entirely with native Apple frameworks—no external dependencies required.

## Features

- **Real-time price tracking** for S&P 500 index funds (FXAIX, SPY, VOO, IVV)
- **Interactive historical charts** with 9 time ranges (1 week to 10 years)
- **Widgets** - Desktop widgets (macOS) and Home Screen/Lock Screen widgets (iPhone, iPad)
- **Auto-refresh** with configurable intervals (1, 5, 20, or 60 minutes)
- **Market state detection** (regular hours, pre-market, post-market, closed)
- **Cross-platform** - Native experience on macOS, iPhone, and iPad

## Requirements

- macOS 14.0+ (Sonoma) or iOS/iPadOS 17.0+
- Xcode 15.0+ (for building)

## Installation

### Build from Source

```bash
git clone https://github.com/slhernandez/SP500Index.git
cd SP500Index
xcodebuild build -scheme SP500Index -configuration Release
open build/Release/SP500Index.app
```

### Development

```bash
# Debug build (macOS)
xcodebuild build -scheme SP500Index -destination 'platform=macOS'

# Debug build (iPhone Simulator)
xcodebuild build -scheme SP500Index -destination 'platform=iOS Simulator,name=iPhone 17'

# Debug build (iPad Simulator)
xcodebuild build -scheme SP500Index -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M5)'

# Build and run (macOS)
xcodebuild build -scheme SP500Index -configuration Debug && open build/Debug/SP500Index.app

# Clean build
xcodebuild clean -scheme SP500Index
```

Or open `SP500Index.xcodeproj` in Xcode and select your target device.

## Distribution

The app is signed with Developer ID and notarized by Apple for distribution outside the Mac App Store.

### Building a Release DMG (Local)

Prerequisites (one-time setup):
1. Developer ID Application certificate (create in Xcode → Settings → Accounts → Manage Certificates)
2. App-specific password from [appleid.apple.com](https://appleid.apple.com)
3. Store notarization credentials:
   ```bash
   xcrun notarytool store-credentials "SP500Index-notarize" \
     --apple-id "your@email.com" \
     --team-id "YOUR_TEAM_ID" \
     --password "your-app-specific-password"
   ```

Build a signed and notarized DMG:

```bash
./scripts/build-release.sh
```

This will:
- Archive and sign the app with Developer ID
- Submit to Apple for notarization
- Staple the notarization ticket
- Create `build/SP500Index.dmg` ready for distribution

### CI/CD with GitHub Actions

The repository includes a GitHub Actions workflow (`.github/workflows/release.yml`) that automatically builds, signs, and notarizes the app when you push a version tag.

**To create a release:**

```bash
git tag v1.0.0
git push origin v1.0.0
```

This triggers the workflow which:
1. Builds and archives the app
2. Signs with Developer ID certificate
3. Submits for Apple notarization
4. Creates a DMG and attaches it to a GitHub Release

**Required GitHub Secrets:**

| Secret | Description |
|--------|-------------|
| `BUILD_CERTIFICATE_BASE64` | Developer ID certificate (.p12), base64 encoded |
| `P12_PASSWORD` | Password for the .p12 file |
| `KEYCHAIN_PASSWORD` | Any random password (for temp CI keychain) |
| `APPLE_ID` | Apple Developer account email |
| `APPLE_APP_SPECIFIC_PASSWORD` | App-specific password for notarization |
| `APPLE_TEAM_ID` | 10-character Apple Team ID |

### Sharing the DMG

The notarized DMG can be distributed via:
- Direct download link
- GitHub Releases (automatic with tag push)
- Any file hosting service

Users can install by:
1. Download `SP500Index.dmg`
2. Double-click to mount
3. Drag `SP500Index.app` to Applications

No Gatekeeper warnings will appear since the app is signed and notarized.

## Usage

1. Launch the app to see the current price of FXAIX (Fidelity 500 Index Fund)
2. Use the time range buttons to view different historical periods
3. Interact with the chart to see specific data points:
   - **macOS:** Hover over the chart
   - **iPhone/iPad:** Drag across the chart
4. Refresh data:
   - **macOS:** Press **Cmd+R** or use the View menu
   - **iPhone/iPad:** Pull down to refresh
5. Change settings:
   - **macOS:** Open **Settings** (Cmd+,) to change the tracked symbol or refresh interval
   - **iPhone/iPad:** Tap the gear icon to access settings

### Supported Symbols

| Symbol | Fund Name |
|--------|-----------|
| FXAIX | Fidelity 500 Index Fund |
| SPY | SPDR S&P 500 ETF |
| VOO | Vanguard S&P 500 ETF |
| IVV | iShares Core S&P 500 ETF |

## Widgets

The app includes widgets for macOS, iPhone, and iPad to monitor prices at a glance without opening the main app.

### Adding Widgets

**macOS:**
1. Right-click on your desktop and select "Edit Widgets..."
2. Search for "S&P 500" in the widget gallery
3. Drag your preferred widget size to the desktop

**iPhone/iPad:**
1. Long-press on the Home Screen and tap the "+" button
2. Search for "S&P 500" in the widget gallery
3. Select a widget size and tap "Add Widget"
4. For Lock Screen widgets: long-press the Lock Screen, tap "Customize", and add to the widget area

### Widget Sizes

| Size | Platform | Display |
|------|----------|---------|
| **Small** | macOS, iPhone, iPad | Symbol, price, daily change, market status |
| **Medium** | macOS, iPhone, iPad | Price info + mini sparkline chart |
| **Large** | macOS, iPhone, iPad | Full details with chart and stats (Open, High, Low, 52W Range) |
| **Circular** | iPhone, iPad (Lock Screen) | Symbol, arrow indicator, percent change |
| **Rectangular** | iPhone, iPad (Lock Screen) | Symbol, price, change details |

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
