//
//  DateFormatters.swift
//  SP500Index
//
//  Date display formatting utilities
//

import Foundation

struct DateFormatters {
    // MARK: - Standard Formatters

    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()

    static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }()

    static let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()

    static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()

    static let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter
    }()

    // MARK: - Relative Formatter

    static let relativeFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter
    }()

    // MARK: - Formatting Methods

    static func formatTime(_ date: Date) -> String {
        timeFormatter.string(from: date)
    }

    static func formatDate(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }

    static func formatDateTime(_ date: Date) -> String {
        dateTimeFormatter.string(from: date)
    }

    static func formatShortDate(_ date: Date) -> String {
        shortDateFormatter.string(from: date)
    }

    static func formatMonthYear(_ date: Date) -> String {
        monthYearFormatter.string(from: date)
    }

    static func formatYear(_ date: Date) -> String {
        yearFormatter.string(from: date)
    }

    static func formatRelative(_ date: Date) -> String {
        relativeFormatter.localizedString(for: date, relativeTo: Date())
    }

    static func formatForTimeRange(_ date: Date, range: TimeRange) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = range.dateFormat
        return formatter.string(from: date)
    }

    static func formatLastUpdated(_ date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "Today at \(formatTime(date))"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday at \(formatTime(date))"
        } else {
            return formatDateTime(date)
        }
    }
}

// MARK: - Convenience Extensions

extension Date {
    var asTime: String {
        DateFormatters.formatTime(self)
    }

    var asDate: String {
        DateFormatters.formatDate(self)
    }

    var asDateTime: String {
        DateFormatters.formatDateTime(self)
    }

    var asRelative: String {
        DateFormatters.formatRelative(self)
    }

    var asLastUpdated: String {
        DateFormatters.formatLastUpdated(self)
    }
}
