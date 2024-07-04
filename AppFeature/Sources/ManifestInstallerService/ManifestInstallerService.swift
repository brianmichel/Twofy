import Foundation

public class ManifestInstallerService: ManifestInstallerServiceProtocol {
    public init() {}
    
    public func install(for applicationID: String, with reply: @escaping ((Error?) -> Void)) {
        guard let app = NativeMessageSource(rawValue: applicationID) else { reply(ManifestInstallationError.unableToConvertIDToModel); return  }

        let directory = app.installationDirectory
        let path = directory.appending(path: "hi.txt", directoryHint: .notDirectory)
        do {
            try "hello".write(to: path, atomically: true, encoding: .utf8)
            reply(nil)
        } catch let writeError {
            reply(ManifestInstallationError.unableToWriteManfiestFile)
        }
    }
    
    public func install(for applicationID: String) async throws -> Error? {
        try await withCheckedThrowingContinuation { continuation in
            install(for: applicationID) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    

}
