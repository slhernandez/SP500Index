//
//  NewsArticle.swift
//  SP500Index
//
//  News article data model
//

import Foundation

struct NewsArticle: Identifiable, Codable {
    let uuid: String
    let title: String
    let publisher: String
    let link: String
    let providerPublishTime: Int

    var id: String { uuid }

    var publishedDate: Date {
        Date(timeIntervalSince1970: TimeInterval(providerPublishTime))
    }

    var relativeTimeString: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: publishedDate, relativeTo: Date())
    }
}

// MARK: - Yahoo Finance Search Response

struct YahooSearchResponse: Codable {
    let news: [NewsArticle]?
}
