import Dependencies
import Foundation
import ManifestInstallerService
import SwiftUI
import Utilities
import XPCSupport

let logger = Logger.for(category: "AppFeature")

extension DependencyValues {
    struct SettingsDependencyKey: DependencyKey {
        static var liveValue = SettingsModel()
    }

    public var settings: SettingsModel {
        get { self[SettingsDependencyKey.self] }
        set { self[SettingsDependencyKey.self] = newValue }
    }
}

public final class SettingsModel: ObservableObject {
    enum ID: String {
        case pollingInterval
        case startOnLogin
        case lookbackWindow
        case needsOnboarding
    }

    @AppStorage(ID.pollingInterval.rawValue) public var pollingInterval: Double = 10
    @AppStorage(ID.startOnLogin.rawValue) public var startOnLogin = false
    @AppStorage(ID.lookbackWindow.rawValue) public var lookbackWindow: Double = 2
    @AppStorage(ID.needsOnboarding.rawValue) public var needsOnboarding: Bool = true

    private let manifestInstaller = XPCService<ManifestInstallerServiceProtocol>(
        connection: NSXPCConnection(serviceName: .manifestInstaller),
        interface: NSXPCInterface(with: ManifestInstallerServiceProtocol.self)
    )

    public init() {
        manifestInstaller.setup { error in
            logger.error("Settings manifestInstaller received error: \(error)")
        }
    }

    func installManifest(for browser: NativeMessageSource) async throws {
        _ = try await manifestInstaller.service?.install(for: browser.rawValue, browserSupportPath: Bundle.main.browserSupportApplicationURL)
    }
}
