//
//  SP500IndexApp.swift
//  SP500Index
//
//  App entry point
//

import SwiftUI

#if os(macOS)
import AppKit
#endif

extension Notification.Name {
    static let manualRefreshRequested = Notification.Name("manualRefreshRequested")
}

@main
struct SP500IndexApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        #if os(macOS)
        .windowStyle(.automatic)
        .defaultSize(width: 500, height: 700)
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About SP500Index") {
                    showAboutPanel()
                }
            }

            CommandGroup(after: .toolbar) {
                Button("Refresh") {
                    NotificationCenter.default.post(name: .manualRefreshRequested, object: nil)
                }
                .keyboardShortcut("r", modifiers: .command)

                Divider()
            }
        }
        #endif

        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }

    #if os(macOS)
    private func showAboutPanel() {
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
    #endif
}

// MARK: - App Delegate (macOS)

#if os(macOS)
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSWindow.allowsAutomaticWindowTabbing = false
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        true
    }
}
#endif
