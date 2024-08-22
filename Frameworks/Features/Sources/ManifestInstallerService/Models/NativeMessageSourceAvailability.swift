import Foundation

public final class NativeMessageSourceAvailability: Codable {
    public enum InstallationStatus: Int, Codable {
        case notInstalled
        case installed
        case installedWithHostManifest
    }

    public let source: NativeMessageSource
    public let installationStatus: InstallationStatus
    public let defaultBrowser: Bool

    public init(source: NativeMessageSource, installationStatus: InstallationStatus, defaultBrowser: Bool) {
        self.source = source
        self.installationStatus = installationStatus
        self.defaultBrowser = defaultBrowser
    }
}
