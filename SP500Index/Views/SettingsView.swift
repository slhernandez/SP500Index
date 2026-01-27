//
//  SettingsView.swift
//  SP500Index
//
//  Preferences window for app settings
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("refreshInterval") private var refreshIntervalMinutes: Int = 5
    @AppStorage("selectedSymbol") private var selectedSymbol: String = "FXAIX"

    var body: some View {
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
        .frame(width: 400, height: 320)
        .navigationTitle("Settings")
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
