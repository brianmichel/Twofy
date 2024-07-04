import Foundation

public enum ManifestInstallationError: Int, Error {
    case unknown = -1
    case installationDirectoryDoesNotExist = 0
    case unableToWriteManfiestFile = 1
    case unableToConvertIDToModel = 2
}

@objc public protocol ManifestInstallerServiceProtocol {
    func install(for applicationID: String, with reply: @escaping ((Error?) -> Void))
    func install(for applicationID: String) async throws -> (any Error)?
}
