import Foundation

@objc public protocol BrowserSupportServiceProtocol {
    func send(code: String, with reply: @escaping ((Error?) -> Void))
    func send(code: String) async throws -> Error?
}
