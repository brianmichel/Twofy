import AppFeature
import Dependencies
import ManifestInstallerService
import SwiftUI
import XPCSupport


final class OnboardingViewModel: ObservableObject {
    @Dependency(\.settings) var settings: SettingsModel

    @Published var needsOnboarding: Bool = false {
        didSet {
            settings.needsOnboarding = needsOnboarding
        }
    }
    @Published var selectedBrowser: NativeMessageSource = .arc

    private let manifestInstaller = XPCService<ManifestInstallerServiceProtocol>(
        connection: NSXPCConnection(serviceName: .manifestInstaller),
        interface: NSXPCInterface(with: ManifestInstallerServiceProtocol.self)
    )

    init() {
        needsOnboarding = settings.needsOnboarding

        manifestInstaller.setup { error in
            logger.error("Manifest installation error: \(error.localizedDescription)")
        }
    }

    func finishOnboarding(with browser: NativeMessageSource) async throws {
        Task { @MainActor in
            needsOnboarding = false
            selectedBrowser = browser
        }

        let browserSupport = Bundle.main.browserSupportApplicationURL
        _ = try await manifestInstaller.service?.install(for: browser.rawValue, browserSupportPath: browserSupport)
    }
}
