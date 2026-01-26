//
//  Colors.swift
//  SP500Widget
//
//  Stock color definitions for widget
//

import SwiftUI

extension Color {
    static let stockGreen = Color(red: 0.2, green: 0.78, blue: 0.35)
    static let stockRed = Color(red: 1.0, green: 0.27, blue: 0.23)

    static func stockColor(isPositive: Bool) -> Color {
        isPositive ? .stockGreen : .stockRed
    }
}
