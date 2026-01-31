//
//  PlatformSupport.swift
//  SP500Index
//
//  Platform-specific utilities for macOS and iOS
//

import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Centralized platform-specific utilities
enum PlatformSupport {

    /// Opens a URL in the system's default browser/handler
    static func openURL(_ url: URL) {
        #if os(macOS)
        NSWorkspace.shared.open(url)
        #else
        UIApplication.shared.open(url)
        #endif
    }

    /// System background color appropriate for the platform
    static var systemBackground: Color {
        #if os(macOS)
        Color(NSColor.windowBackgroundColor)
        #else
        Color(.systemBackground)
        #endif
    }
}
