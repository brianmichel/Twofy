import Foundation

public class ManifestInstallerService: ManifestInstallerServiceProtocol {
    public init() {}
    
    public func install(for applicationID: String, browserSupportPath: URL, with reply: @escaping ((Error?) -> Void)) {
        guard let app = NativeMessageSource(rawValue: applicationID) else { reply(ManifestInstallationError.unableToConvertIDToModel); return  }

        let directory = app.installationDirectory
        let path = directory.appending(path: "me.foureyes.twofy.json", directoryHint: .notDirectory)
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted]
            let data = try encoder.encode(app.manifest(with: browserSupportPath.path(percentEncoded: false)))

            guard let string = String(data: data, encoding: .utf8) else { reply(ManifestInstallationError.unableToGenerateManifestJSON); return }
            try string.write(to: path, atomically: true, encoding: .utf8)
            reply(nil)
        } catch {
            reply(ManifestInstallationError.unableToWriteManfiestFile)
        }
    }
    
    public func install(for applicationID: String, browserSupportPath: URL) async throws -> Error? {
        try await withCheckedThrowingContinuation { continuation in
            install(for: applicationID, browserSupportPath: browserSupportPath) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
