import AppFeature
import BrowserSupportService
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

    private let serviceBroker = XPCService<ServiceBrokerServiceProtocol>(
        connection: NSXPCConnection(machServiceName: .serviceBroker),
        interface: NSXPCInterface(with: ServiceBrokerServiceProtocol.self)
    )

    private var browserSupport: XPCService<BrowserSupportServiceProtocol>?

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
    let loginItem = SMAppService.loginItem(identifier: "YN24FFRTC8.me.foureyes.Twofy.ServiceBroker")

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

            serviceBroker.setup { error in
                logger.error("Error from service broker: \(error.localizedDescription)")
            }
            serviceBroker.service?.registerMainApplication(with: { [weak self] browserSupportEndpoint in
                guard let self else { return }
                DispatchQueue.main.async {
                    logger.debug("Received BrowserSupport process endpoint: \(browserSupportEndpoint)")
                    self.browserSupport = .init(
                        connection: NSXPCConnection(listenerEndpoint: browserSupportEndpoint),
                        interface: NSXPCInterface(with: BrowserSupportServiceProtocol.self))

                    self.browserSupport?.setup(errorHandler: { error in
                        logger.error("Error from browserSupport Process: \(error.localizedDescription)")
                    })
                }
            })

            error = nil
        } catch let error {
            self.error = error
        }
    }

    func send(code: String) {
        Task {
            try! await browserSupport?.service?.send(code: code)
        }
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

        listener.start(lookback: .minutes(10))
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
