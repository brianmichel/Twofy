import Foundation

public enum ManifestInstallationError: Int, Error {
    case unknown = -1
    case installationDirectoryDoesNotExist
    case unableToGenerateManifestJSON
    case unableToWriteManfiestFile
    case unableToConvertIDToModel
}

@objc public protocol ManifestInstallerServiceProtocol {
    func install(for applicationID: String, browserSupportPath: URL, with reply: @escaping ((Error?) -> Void))
    func install(for applicationID: String, browserSupportPath: URL) async throws -> Error?
}
