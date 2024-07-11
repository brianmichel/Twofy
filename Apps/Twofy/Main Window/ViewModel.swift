import AppFeature
import DistributedNotificationIPC
import Foundation
import ManifestInstallerService
import MessageDatabaseListener
import ExtensionMessageBus
import ServiceBrokerService
import ServiceManagement
import SwiftUI
import Utilities
import XPCSupport

private let logger = Logger.for(category: "ViewModel")

final class ViewModel: ObservableObject {
    @Published var messages = [Message]() {
        didSet {
            guard let first = messages.first, let code = first.extractedCode() else { return }
            send(code: code)
        }
    }
    @Published var databaseFolder: URL? {
        didSet {
            guard let databaseFolder else { return }
            setupListener(for: databaseFolder.appending(path: "chat.db", directoryHint: .notDirectory))
        }
    }

    @Published var error: (any Error)? = nil

    private(set) var listener: MessageDatabaseListener?

    private let manifestInstaller = XPCService<ManifestInstallerServiceProtocol>(
        connection: NSXPCConnection(serviceName: .manifestInstaller),
        interface: NSXPCInterface(with: ManifestInstallerServiceProtocol.self)
    )

    @Published var findingCodes: Bool = false {
        didSet {
            if findingCodes {
                startFindingCodes()
            } else {
                stopFindingCodes()
            }
        }
    }
    private var findMessagesTask: Task<Void, (any Error)>?

    func setupListener(for path: URL) {
        do {
            listener = try MessageDatabaseListener(path: path)
            manifestInstaller.setup { error in
                logger.error("Error from manifest installer service \(error)")
            }
            manifestInstaller.service?.install(for: .describing(NativeMessageSource.arc), with: { error in
                if let installerError = error as? ManifestInstallationError {
                    logger.error("Manifest installation error \(installerError)")
                }
            })

            error = nil
        } catch let error {
            self.error = error
        }
    }

    func send(code: String) {
        BrowserSupportIPCNotificationMessage.send(.foundCode(code))
    }

    private func startFindingCodes() {
        guard let listener else { return }
        stopFindingCodes()

        findMessagesTask = Task {
            for try await messages in listener.stream {
                Task { @MainActor in
                    self.messages = messages.filter({ $0.extractedCode() != nil })
                }
            }
        }

        listener.start(lookback: .days(2))
    }

    private func stopFindingCodes() {
        findMessagesTask?.cancel()
        findMessagesTask = nil
    }
}

extension ViewModel {
    static func stub() -> ViewModel {
        let model = ViewModel()
        model.messages = [
            .stub(id: 0, code: "34343"),
            .stub(id: 1, code: "333"),
            .stub(id: 2, code: "90809"),
            .stub(id: 3, code: "2391"),
            .stub(id: 4, code: "2919"),
            .stub(id: 5, code: "880723")
        ]

        return model
    }
}
