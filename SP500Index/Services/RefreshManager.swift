//
//  RefreshManager.swift
//  SP500Index
//
//  Auto-update timer logic for refreshing data
//

import Foundation
import Combine

@MainActor
class RefreshManager: ObservableObject {
    @Published var isAutoRefreshEnabled: Bool = true
    @Published var nextRefreshDate: Date?

    private var timer: Timer?
    private var refreshAction: (() async -> Void)?
    private var intervalMinutes: Int = 5

    var timeUntilNextRefresh: TimeInterval? {
        guard let nextRefresh = nextRefreshDate else { return nil }
        return nextRefresh.timeIntervalSinceNow
    }

    func configure(intervalMinutes: Int, action: @escaping () async -> Void) {
        self.intervalMinutes = intervalMinutes
        self.refreshAction = action
    }

    func start() {
        stop()

        guard isAutoRefreshEnabled else { return }

        let interval = TimeInterval(intervalMinutes * 60)
        nextRefreshDate = Date().addingTimeInterval(interval)

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.performRefresh()
            }
        }

        // Make sure timer fires even when scrolling
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        nextRefreshDate = nil
    }

    func updateInterval(_ minutes: Int) {
        intervalMinutes = minutes
        if isAutoRefreshEnabled {
            start()
        }
    }

    func triggerManualRefresh() async {
        await performRefresh()
        // Reset the timer after manual refresh
        if isAutoRefreshEnabled {
            start()
        }
    }

    private func performRefresh() async {
        await refreshAction?()

        if isAutoRefreshEnabled {
            nextRefreshDate = Date().addingTimeInterval(TimeInterval(intervalMinutes * 60))
        }
    }

    deinit {
        timer?.invalidate()
    }
}
