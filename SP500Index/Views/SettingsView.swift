//
//  SettingsView.swift
//  SP500Index
//
//  Preferences window for app settings
//

import SwiftUI

#if os(macOS)
import SP500IndexUpdates
#endif

struct SettingsView: View {
    @AppStorage("refreshInterval") private var refreshIntervalMinutes: Int = 5
    @AppStorage("selectedSymbol") private var selectedSymbol: String = "^GSPC"
    @AppStorage("marketCategory") private var marketCategory: String = "us"
    @AppStorage("investedAmount") private var investedAmount: Double = 0
    #if os(macOS)
    private let updater: AppUpdater?
    #endif
    #if os(iOS)
    @Environment(\.dismiss) private var dismiss
    #endif

    #if os(macOS)
    init(updater: AppUpdater? = nil) {
        self.updater = updater
    }
    #else
    init() {}
    #endif

    var body: some View {
        #if os(iOS)
        NavigationStack {
            settingsForm
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
        }
        #else
        settingsForm
            .frame(width: 400, height: 540)
            .navigationTitle("Settings")
        #endif
    }

    private var settingsForm: some View {
        Form {
            Section {
                Picker("Update Frequency", selection: $refreshIntervalMinutes) {
                    ForEach(RefreshInterval.allCases) { interval in
                        Text(interval.displayName)
                            .tag(interval.rawValue)
                    }
                }
                .pickerStyle(.menu)

                Text("Data will automatically refresh at this interval when the app is running.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } header: {
                Text("Refresh")
            }

            Section {
                Picker("Default Category", selection: $marketCategory) {
                    ForEach(MarketCategory.allCases) { category in
                        Text(category.displayName)
                            .tag(category.rawValue)
                    }
                }
                .pickerStyle(.menu)

                Text("Select which market indices to display in the overview bar")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } header: {
                Text("Market Overview")
            }

            Section {
                Picker("Index Fund", selection: $selectedSymbol) {
                    Text("^GSPC - S&P 500 Index").tag("^GSPC")
                    Text("FXAIX - Fidelity 500 Index").tag("FXAIX")
                    Text("SPY - SPDR S&P 500 ETF").tag("SPY")
                    Text("VOO - Vanguard S&P 500 ETF").tag("VOO")
                    Text("IVV - iShares Core S&P 500").tag("IVV")
                }
                .pickerStyle(.menu)

                Text("^GSPC is the S&P 500 index (updates at close). FXAIX is a mutual fund (updates at close). ETFs (SPY, VOO, IVV) update throughout trading hours.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } header: {
                Text("Data Source")
            }

            Section {
                HStack {
                    Text("$")
                        .foregroundColor(.secondary)
                    TextField("Amount", value: $investedAmount, format: .number.precision(.fractionLength(0...2)))
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                }

                Text("Enter your total invested amount to see dollar gain/loss in the price header and chart summary.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } header: {
                Text("Investment Tracking")
            }

            #if os(macOS)
            if let updater {
                UpdateSettingsSection(appUpdater: updater)
            }
            #endif

            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.appVersion)
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Data Provider")
                    Spacer()
                    Text("Yahoo Finance")
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("About")
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - Bundle Extension

extension Bundle {
    var appVersion: String {
        let version = infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}
