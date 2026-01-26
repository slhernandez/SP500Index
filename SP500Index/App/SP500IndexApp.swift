//
//  SP500IndexApp.swift
//  SP500Index
//
//  App entry point
//

import SwiftUI

@main
struct SP500IndexApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel = StockViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 500, height: 700)
        .commands {
            // Replace standard app menu items
            CommandGroup(replacing: .appInfo) {
                Button("About SP500Index") {
                    NSApplication.shared.orderFrontStandardAboutPanel(
                        options: [
                            .applicationName: "SP500Index",
                            .applicationVersion: Bundle.main.appVersion,
                            .credits: NSAttributedString(
                                string: "S&P 500 Index Fund Tracker\nData provided by Yahoo Finance",
                                attributes: [
                                    .font: NSFont.systemFont(ofSize: 11),
                                    .foregroundColor: NSColor.secondaryLabelColor
                                ]
                            )
                        ]
                    )
                }
            }

            // View menu commands
            CommandGroup(after: .toolbar) {
                Button("Refresh") {
                    Task {
                        await viewModel.manualRefresh()
                    }
                }
                .keyboardShortcut("r", modifiers: .command)

                Divider()
            }
        }

        // Settings window
        Settings {
            SettingsView()
        }
    }
}

// MARK: - App Delegate

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Configure app appearance
        NSWindow.allowsAutomaticWindowTabbing = false
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }
}
