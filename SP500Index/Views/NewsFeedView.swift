//
//  NewsFeedView.swift
//  SP500Index
//
//  News feed section displaying market news
//

import SwiftUI

struct NewsFeedView: View {
    let articles: [NewsArticle]

    #if os(iOS)
    @Environment(\.horizontalSizeClass) var sizeClass
    #endif

    private var columns: [GridItem] {
        #if os(iOS)
        if sizeClass == .compact {
            return [GridItem(.flexible(), spacing: 16)]
        }
        #endif
        return [
            GridItem(.flexible(), spacing: 16),
            GridItem(.flexible(), spacing: 16)
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            VStack(alignment: .leading, spacing: 2) {
                Text("News stories")
                    .font(.title3)
                Text("From sources across the web")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // News grid
            if articles.isEmpty {
                Text("No news available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                    ForEach(articles) { article in
                        NewsArticleRow(article: article)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - News Article Row

struct NewsArticleRow: View {
    let article: NewsArticle
    #if os(macOS)
    @State private var isHovering = false
    #endif

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Publisher and time
            HStack(spacing: 4) {
                Text(article.publisher)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                Text("·")
                    .foregroundColor(.secondary)
                Text(article.relativeTimeString)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .lineLimit(1)

            // Headline
            Text(article.title)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            openArticle()
        }
        #if os(macOS)
        .onHover { hovering in
            isHovering = hovering
            if hovering {
                NSCursor.pointingHand.set()
            } else {
                NSCursor.arrow.set()
            }
        }
        #endif
    }

    private func openArticle() {
        guard let url = URL(string: article.link) else { return }
        PlatformSupport.openURL(url)
    }
}

// MARK: - Preview

#Preview {
    NewsFeedView(articles: [
        NewsArticle(
            uuid: "1",
            title: "S&P 500 Hits All-Time High, Eyes 7,000 Level, As Stock Market Awaits Earnings",
            publisher: "Investor's Business Daily",
            link: "https://example.com",
            providerPublishTime: Int(Date().timeIntervalSince1970) - 3600
        ),
        NewsArticle(
            uuid: "2",
            title: "Markets News: S&P 500 Hits All-Time High; Nasdaq Soars as Tech Stocks Rally",
            publisher: "Investopedia",
            link: "https://example.com",
            providerPublishTime: Int(Date().timeIntervalSince1970) - 7200
        ),
        NewsArticle(
            uuid: "3",
            title: "S&P 500 futures are little changed ahead of Fed decision",
            publisher: "CNBC",
            link: "https://example.com",
            providerPublishTime: Int(Date().timeIntervalSince1970) - 10800
        ),
        NewsArticle(
            uuid: "4",
            title: "Stock Market Today: Tech lifts S&P 500 to fresh record",
            publisher: "TheStreet",
            link: "https://example.com",
            providerPublishTime: Int(Date().timeIntervalSince1970) - 14400
        )
    ])
    .padding()
    .frame(width: 500)
}
