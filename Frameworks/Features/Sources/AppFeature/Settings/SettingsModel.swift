import Dependencies
import Foundation
import ManifestInstallerService
import SwiftUI
import Utilities
import XPCSupport
import SwiftyXPC

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

    @Published
    public private(set) var availableSources = [NativeMessageSourceAvailability]()

    private let connection: XPCConnection

    public init() {
        connection = try! XPCConnection(type: .remoteService(bundleID: .manifestInstaller))
        connection.errorHandler = { _, error in
            logger.error("Settings manifestInstaller received error: \(error)")
        }

        connection.resume()
    }

    func installManifest(for browser: NativeMessageSource) async throws {
        try await connection.sendMessage(
            name: ManifestInstallerService.Commands.installManifest,
            request: ManifestInstallRequest(application: browser, browserSupportPath: Bundle.main.browserSupportApplicationURL)
        )
    }

    func fetchAvailableBrowsers() async throws -> [NativeMessageSourceAvailability] {
        return try await connection.sendMessage(name: ManifestInstallerService.Commands.findNativeMessageSources)
    }
}
