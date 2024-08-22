import Foundation
import AppKit
import SwiftyXPC

public enum ManifestInstallError: Error {
    case unableToGenerateManifestJSON
}

public class ManifestInstallerService {
    public enum Commands {
        public static let installManifest = "me.foureyes.Twofy.installManifest"
        public static let findNativeMessageSources = "me.foureyes.Twofy.findNativeMessageSources"
    }

    public init() {}

    public func install(_: XPCConnection, request: ManifestInstallRequest) async throws {
        let path = request.application.manifestPath
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        let data = try encoder.encode(request.application.manifest(with: request.browserSupportPath.path(percentEncoded: false)))

        guard let string = String(data: data, encoding: .utf8) else { throw ManifestInstallError.unableToGenerateManifestJSON }
        try string.write(to: path, atomically: true, encoding: .utf8)
    }

    public func findSources(_: XPCConnection) async -> [NativeMessageSourceAvailability] {
        var availabilities = [NativeMessageSourceAvailability]()
        let workspace = NSWorkspace.shared
        let defaultBrowserApplicationPath = workspace.urlForApplication(toOpen: URL(string: "https://www.twofy.xyz")!)

        for source in NativeMessageSource.allCases {
            let path = workspace.urlForApplication(withBundleIdentifier: source.bundleIdentifier)
            if let path {
                let manifestPath = source.manifestPath
                let manifestExists = FileManager.default.fileExists(atPath: manifestPath.path(percentEncoded: false))

                let isDefault = defaultBrowserApplicationPath == path
                availabilities.append(NativeMessageSourceAvailability(source: source, installationStatus: manifestExists ? .installedWithHostManifest : .installed, defaultBrowser: isDefault))
            } else {
                availabilities.append(NativeMessageSourceAvailability(source: source, installationStatus: .notInstalled, defaultBrowser: false))
            }
        }
        return availabilities
    }
}
