import SwiftUI

#if os(macOS)
import Combine
import Sparkle

@MainActor
public final class AppUpdater: ObservableObject {
    fileprivate let updaterController: SPUStandardUpdaterController?
    public let isConfigured: Bool

    public init() {
        let publicKey = (Bundle.main.object(forInfoDictionaryKey: "SUPublicEDKey") as? String ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let feedURL = (Bundle.main.object(forInfoDictionaryKey: "SUFeedURL") as? String ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        isConfigured = !publicKey.isEmpty && !feedURL.isEmpty

        if isConfigured {
            updaterController = SPUStandardUpdaterController(
                startingUpdater: true,
                updaterDelegate: nil,
                userDriverDelegate: nil
            )
        } else {
            updaterController = nil
        }
    }
}

@MainActor
final class SparkleUpdaterViewModel: ObservableObject {
    @Published private(set) var isConfigured: Bool
    @Published private(set) var canCheckForUpdates: Bool
    @Published var automaticallyChecksForUpdates: Bool

    private let updater: SPUUpdater?
    private var cancellables = Set<AnyCancellable>()

    init(appUpdater: AppUpdater) {
        let updater = appUpdater.updaterController?.updater

        self.isConfigured = appUpdater.isConfigured
        self.updater = updater
        self.canCheckForUpdates = updater?.canCheckForUpdates ?? false
        self.automaticallyChecksForUpdates = updater?.automaticallyChecksForUpdates ?? false

        guard let updater else {
            return
        }

        updater.publisher(for: \.canCheckForUpdates)
            .receive(on: RunLoop.main)
            .assign(to: &$canCheckForUpdates)

        updater.publisher(for: \.automaticallyChecksForUpdates)
            .receive(on: RunLoop.main)
            .assign(to: &$automaticallyChecksForUpdates)

        $automaticallyChecksForUpdates
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] newValue in
                self?.updater?.automaticallyChecksForUpdates = newValue
            }
            .store(in: &cancellables)
    }

    func checkForUpdates() {
        updater?.checkForUpdates()
    }
}

public struct CheckForUpdatesView: View {
    @StateObject private var viewModel: SparkleUpdaterViewModel

    public init(appUpdater: AppUpdater) {
        _viewModel = StateObject(wrappedValue: SparkleUpdaterViewModel(appUpdater: appUpdater))
    }

    public var body: some View {
        Button("Check for Updates…") {
            viewModel.checkForUpdates()
        }
        .disabled(!viewModel.isConfigured || !viewModel.canCheckForUpdates)
    }
}

public struct UpdateSettingsSection: View {
    @StateObject private var viewModel: SparkleUpdaterViewModel

    public init(appUpdater: AppUpdater) {
        _viewModel = StateObject(wrappedValue: SparkleUpdaterViewModel(appUpdater: appUpdater))
    }

    public var body: some View {
        Section {
            Toggle("Automatically check for updates", isOn: $viewModel.automaticallyChecksForUpdates)
                .disabled(!viewModel.isConfigured)

            Text(updateDescription)
                .font(.caption)
                .foregroundColor(.secondary)
        } header: {
            Text("Updates")
        }
    }

    private var updateDescription: String {
        if viewModel.isConfigured {
            return "When enabled, SP500Index checks for new versions once per day in the background."
        }

        return "Set the Sparkle public key in the Xcode build settings to enable automatic update checks."
    }
}
#endif
