import Foundation

extension Notification.Name {
    public static let browserSupport = Notification.Name("me.foureyes.Twofy.BrowserSupportIPCNotification")
    public static let mainApplication = Notification.Name("me.foureyes.Twofy.IPCNotification")
}

public struct BrowserSupportIPCNotificationMessage: Identifiable, Codable {
    public enum Action: Codable {
        case foundCode(String)
    }

    public var id = UUID()
    public var action: Action
}

extension BrowserSupportIPCNotificationMessage {
    public static func send(_ action: Action) {
        let message = BrowserSupportIPCNotificationMessage(action: action)
        let data = try! PropertyListEncoder().encode(message)

        DistributedNotificationCenter
            .default()
            .postNotificationName(.browserSupport,
                                  object: data.base64EncodedString(),
                                  deliverImmediately: true)
    }

    public static func receive(with block: @escaping (BrowserSupportIPCNotificationMessage) -> Void) {
        DistributedNotificationCenter
            .default()
            .addObserver(forName: .browserSupport, object: nil, queue: .main) { notification in
                guard let base64 = notification.object as? String else { return }
                guard let data = Data(base64Encoded: base64) else { return }
                let decoded = try! PropertyListDecoder().decode(BrowserSupportIPCNotificationMessage.self, from: data)
                block(decoded)
            }
    }
}
