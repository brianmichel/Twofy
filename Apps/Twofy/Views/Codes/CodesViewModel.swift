import AppFeature
import Dependencies
import DistributedNotificationIPC
import Foundation
import MessageDatabaseListener

final class CodesViewModel: ObservableObject {
    @Dependency(\.settings) var settings

    @Published var findingCodes: Bool = false {
        didSet {
            if findingCodes {
                startPolling()
            } else {
                stopPolling()
            }
        }
    }

    @Published var messages: [Message] = []

    private let listener: MessageDatabaseListener
    private var pollingTask: Task<Void, Error>?
    private var sentMessageIDs = Set<Int64>()

    init(databasePath path: URL) throws {
        listener = try MessageDatabaseListener(path: path)
    }

    func send(code: String) {
        BrowserSupportIPCNotificationMessage.send(.foundCode(code))
    }

    private func startPolling() {
        stopPolling()

        pollingTask = Task {
            for try await messages in listener.stream {
                let filteredMessages = messages.filter({ $0.extractedCode() != nil })
                Task { @MainActor in
                    self.messages = filteredMessages
                }
            }
        }

        listener.start(lookback: .minutes(Int(settings.lookbackWindow)), pollingInterval: settings.pollingInterval)
    }

    private func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
        messages.removeAll()
    }
}

extension CodesViewModel {
    static func stub() -> CodesViewModel {
        let model = try! CodesViewModel(databasePath: URL(fileURLWithPath: "/dev/null"))
        model.messages = [
            .stub(id: 0, code: "2343"),
            .stub(id: 1, code: "94902"),
            .stub(id: 2, code: "81716"),
            .stub(id: 3, code: "2820"),
            .stub(id: 4, code: "988820"),
            .stub(id: 5, code: "80761"),
        ]

        return model
    }
}
