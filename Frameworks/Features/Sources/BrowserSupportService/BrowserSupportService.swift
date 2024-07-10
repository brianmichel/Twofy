import Foundation
import ExtensionMessageBus

public class BrowserSupportService: BrowserSupportServiceProtocol {
    private let bus = ExtensionMessageBus()

    public init() throws {
        try bus.start()
    }

    public func send(code: String, with reply: @escaping ((Error?) -> Void)) {
        bus.send(.code(code))
    }

    public func send(code: String) async throws -> Error? {
        try await withCheckedThrowingContinuation { continuation in
            send(code: code) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    deinit {
        bus.stop()
    }
}
