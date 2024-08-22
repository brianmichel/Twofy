import Foundation

public struct ManifestInstallRequest: Codable {
    public let application: NativeMessageSource
    public let browserSupportPath: URL

    public init(application: NativeMessageSource, browserSupportPath: URL) {
        self.application = application
        self.browserSupportPath = browserSupportPath
    }
}
