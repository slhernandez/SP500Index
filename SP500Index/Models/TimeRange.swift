//
//  TimeRange.swift
//  SP500Index
//
//  Time range enumeration for chart periods
//

import Foundation

enum TimeRange: String, CaseIterable, Identifiable, Codable {
    case oneDay = "1D"
    case oneWeek = "1W"
    case oneMonth = "1M"
    case threeMonths = "3M"
    case sixMonths = "6M"
    case yearToDate = "YTD"
    case oneYear = "1Y"
    case twoYears = "2Y"
    case fiveYears = "5Y"
    case tenYears = "10Y"

    var id: String { rawValue }

    var displayName: String { rawValue }

    /// Yahoo Finance API range parameter
    var apiRange: String {
        switch self {
        case .oneDay: return "1d"
        case .oneWeek: return "5d"
        case .oneMonth: return "1mo"
        case .threeMonths: return "3mo"
        case .sixMonths: return "6mo"
        case .yearToDate: return "ytd"
        case .oneYear: return "1y"
        case .twoYears: return "2y"
        case .fiveYears: return "5y"
        case .tenYears: return "10y"
        }
    }

    /// Yahoo Finance API interval parameter
    var apiInterval: String {
        switch self {
        case .oneDay: return "5m"
        case .oneWeek: return "1d"
        case .oneMonth: return "1d"
        case .threeMonths: return "1d"
        case .sixMonths: return "1d"
        case .yearToDate: return "1d"
        case .oneYear: return "1wk"
        case .twoYears: return "1wk"
        case .fiveYears: return "1mo"
        case .tenYears: return "1mo"
        }
    }

    /// Human-readable description
    var description: String {
        switch self {
        case .oneDay: return "1 Day"
        case .oneWeek: return "1 Week"
        case .oneMonth: return "1 Month"
        case .threeMonths: return "3 Months"
        case .sixMonths: return "6 Months"
        case .yearToDate: return "Year to Date"
        case .oneYear: return "1 Year"
        case .twoYears: return "2 Years"
        case .fiveYears: return "5 Years"
        case .tenYears: return "10 Years"
        }
    }

    /// Date format to use for chart labels
    var dateFormat: String {
        switch self {
        case .oneDay: return "h a"
        case .oneWeek: return "EEE"
        case .oneMonth: return "MMM d"
        case .threeMonths, .sixMonths, .yearToDate: return "MMM d"
        case .oneYear, .twoYears: return "MMM yyyy"
        case .fiveYears, .tenYears: return "yyyy"
        }
    }
}

enum RefreshInterval: Int, CaseIterable, Identifiable {
    case oneMinute = 1
    case fiveMinutes = 5
    case twentyMinutes = 20
    case oneHour = 60

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .oneMinute: return "1 minute"
        case .fiveMinutes: return "5 minutes"
        case .twentyMinutes: return "20 minutes"
        case .oneHour: return "1 hour"
        }
    }

    var seconds: TimeInterval {
        TimeInterval(rawValue * 60)
    }
}
