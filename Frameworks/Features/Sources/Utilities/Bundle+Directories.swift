import Foundation

extension Bundle {
    public var browserSupportApplicationURL: URL {
        return helperApp(named: "Twofy Browser Support", extension: "app")
    }

    public func helperApp(named: String, extension: String) -> URL {
        bundleURL
            .appending(component: "Contents", directoryHint: .isDirectory)
            .appending(path: "Helpers", directoryHint: .isDirectory)
            .appending(component: "\(named).\(`extension`)", directoryHint: .isDirectory)
            .appending(component: "Contents", directoryHint: .isDirectory)
            .appending(component: "MacOS", directoryHint: .isDirectory)
            .appending(component: named, directoryHint: .notDirectory)
    }
}
