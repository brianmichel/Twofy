import Foundation
import Utilities

public enum NativeMessageSource: String, Sendable {
    case chrome
    case arc
    case edge
}

extension NativeMessageSource {
    var installationDirectory: URL {
        let basePath: URL = .realHomeDirectory
            .appending(path: "Library", directoryHint: .isDirectory)
            .appending(path: "Application Support", directoryHint: .isDirectory)

        switch self {
        case .chrome:
            return basePath
                .appending(path: "Google", directoryHint: .isDirectory)
                .appending(path: "Chrome", directoryHint: .isDirectory)
                .appending(path: "NativeMessagingHosts", directoryHint: .isDirectory)
        case .arc:
            return basePath
                .appending(path: "Arc", directoryHint: .isDirectory)
                .appending(path: "User Data", directoryHint: .isDirectory)
                .appending(path: "NativeMessagingHosts", directoryHint: .isDirectory)
        case .edge:
            return basePath
                .appending(path: "Microsoft Edge", directoryHint: .isDirectory)
                .appending(path: "NativeMessagingHosts", directoryHint: .isDirectory)
        }
    }
}
