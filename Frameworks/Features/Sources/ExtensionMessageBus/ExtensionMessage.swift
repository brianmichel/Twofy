import Foundation

public enum ExtensionMessage: Equatable, Sendable {
    /// Used to classify unknown messages and their payloads as needed.
    case unknown(String)
    /// Sent when a 2FA code has been looked up in the chat database.
    case code(String)
    /// Sent when the database poller has timed out and no message could be found.
    case pollingTimeout
}

extension Int {
    static let messageHeaderLength: Self = 4
}

extension ExtensionMessage {
    var actionJSON: [String: Any] {
        switch self {
        case let .unknown(data):
            return [
                "action": "unknown",
                "data": data
            ]
        case let .code(data):
            return [
                "action": "code",
                "data": data
            ]
        case .pollingTimeout:
            return [
                "action": "pollingTimeout"
            ]
        }
    }
}
