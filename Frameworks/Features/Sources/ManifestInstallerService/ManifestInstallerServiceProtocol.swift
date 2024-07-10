import Foundation

public enum ManifestInstallationError: Int, Error {
    case unknown = -1
    case installationDirectoryDoesNotExist
    case unableToGenerateManifestJSON
    case unableToWriteManfiestFile
    case unableToConvertIDToModel
}

@objc public protocol ManifestInstallerServiceProtocol {
    func install(for applicationID: String, with reply: @escaping ((Error?) -> Void))
    func install(for applicationID: String) async throws -> Error?
}
