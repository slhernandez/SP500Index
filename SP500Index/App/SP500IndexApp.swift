//
//  SP500IndexApp.swift
//  SP500Index
//
//  App entry point
//

import SwiftUI

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

@main
struct SP500IndexApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #elseif os(iOS)
    @UIApplicationDelegateAdaptor(iOSAppDelegate.self) var appDelegate
    #endif

    @StateObject private var viewModel = StockViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
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
                    Task {
                        await viewModel.manualRefresh()
                    }
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

// MARK: - App Delegate (iOS)

#if os(iOS)
class iOSAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        config.delegateClass = iOSSceneDelegate.self
        return config
    }
}

class iOSSceneDelegate: NSObject, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // Set window background color to prevent black edges in safe areas
        DispatchQueue.main.async {
            for window in windowScene.windows {
                window.backgroundColor = .systemBackground
            }
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        guard let windowScene = scene as? UIWindowScene else { return }

        // Ensure background color is set after scene becomes active
        for window in windowScene.windows {
            if window.backgroundColor == nil {
                window.backgroundColor = .systemBackground
            }
        }
    }
}
#endif
