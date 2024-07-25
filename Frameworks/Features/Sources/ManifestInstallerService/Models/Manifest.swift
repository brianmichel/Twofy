import Foundation

public enum ExtensionID: String, Codable {
    // N.B. The trailing `/` must be present otherwise these may fail to decode
    // correctly when trying to load the native message host.
    case chromiumProduction = "chrome-extension://gfkpgomgmghnffbledjbhcfcllpdgjog/"
    case chromiumDebug = "chrome-extension://dmlknddeegiihclfnlcgpnekbgahbime/"
}

// Manifest format can be found with more detail
// online here https://developer.chrome.com/docs/extensions/develop/concepts/native-messaging#native-messaging-host
public struct Manifest: Codable {
    public let name: String
    public let description: String
    public let path: String
    public let type: String
    public let allowedOrigins: [ExtensionID]

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case path
        case type
        case allowedOrigins = "allowed_origins"
    }
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
