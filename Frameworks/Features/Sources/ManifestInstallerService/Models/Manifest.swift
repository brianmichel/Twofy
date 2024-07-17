import Foundation

public enum ExtensionID: String, Codable {
    case chromiumProduction = "chrome-extension://gfkpgomgmghnffbledjbhcfcllpdgjog"
    case chromiumDebug = "chrome-extension://dmlknddeegiihclfnlcgpnekbgahbime"
}

public struct Manifest: Codable {
    public let name: String
    public let description: String
    public let path: String
    public let type: String
    public let allowedOrigins: [ExtensionID]
}

extension Manifest {
    public static func twofyChromiumBrowserSupport(with executablePath: String) -> Self {
        var origins: [ExtensionID] = [.chromiumProduction]
        #if DEBUG
        origins.append(.chromiumDebug)
        #endif

        return .init(
            name: "me.foureyes.twofy",
            description: "Twofy Browser Support",
            path: executablePath,
            type: "stdio",
            allowedOrigins: origins)
    }
}
