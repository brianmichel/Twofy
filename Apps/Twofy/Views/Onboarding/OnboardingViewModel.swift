import AppFeature
import Dependencies
import ManifestInstallerService
import SwiftUI
import SwiftyXPC

final class OnboardingViewModel: ObservableObject {
    @Dependency(\.settings) var settings: SettingsModel

    @Published var needsOnboarding: Bool = false {
        didSet {
            settings.needsOnboarding = needsOnboarding
        }
    }
    @Published var selectedBrowser: NativeMessageSource = .arc

    private let connection: XPCConnection

    init() {
        connection = try! XPCConnection(type: .remoteService(bundleID: .manifestInstaller))
        connection.errorHandler = { _, error in
            logger.error("Onbarding manifestInstaller received error: \(error)")
        }

        connection.resume()

        needsOnboarding = settings.needsOnboarding
    }

    func finishOnboarding(with browser: NativeMessageSource) async throws {
        Task { @MainActor in
            needsOnboarding = false
            selectedBrowser = browser
        }

        let browserSupport = Bundle.main.browserSupportApplicationURL
        try await connection.sendMessage(
            name: ManifestInstallerService.Commands.installManifest,
            request: ManifestInstallRequest(application: browser, browserSupportPath: browserSupport)
        )
    }
}
