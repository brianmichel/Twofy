import Foundation
import Utilities

public enum NativeMessageSource: String, Sendable, CaseIterable, Codable, Equatable {
    case arc
    case brave
    case chrome
    case edge
}

extension NativeMessageSource {
    public var installationDirectory: URL {
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
        case .brave:
            return basePath
                .appending(path: "BraveSoftware", directoryHint: .isDirectory)
                .appending(path: "Brave-Browser", directoryHint: .isDirectory)
                .appending(path: "NativeMessagingHosts", directoryHint: .isDirectory)
        }
    }

    public var manifestPath: URL {
        return installationDirectory.appending(component: "me.foureyes.twofy.json", directoryHint: .notDirectory)
    }

    public func manifest(with executablePath: String) -> Manifest {
        switch self {
        case .arc:
            return .twofyChromiumBrowserSupport(with: executablePath)
        case .brave:
            return .twofyChromiumBrowserSupport(with: executablePath)
        case .chrome:
            return .twofyChromiumBrowserSupport(with: executablePath)
        case .edge:
            return .twofyChromiumBrowserSupport(with: executablePath)
        }
    }

    public var name: String {
        switch self {
        case .arc:
            return "Arc"
        case .edge:
            return "Microsoft Edge"
        case .chrome:
            return "Google Chrome"
        case .brave:
            return "Brave Browser"
        }
    }

    public var bundleIdentifier: String {
        switch self {
        case .arc:
            return "company.thebrowser.Browser"
        case .edge:
            return "com.microsoft.edgemac"
        case .chrome:
            return "com.google.Chrome"
        case .brave:
            return "com.brave.Browser"
        }
    }
}

extension NativeMessageSource: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}
