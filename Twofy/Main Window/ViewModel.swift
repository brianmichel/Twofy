//
//  ViewModel.swift
//  Twofy
//
//  Created by Brian Michel on 6/23/24.
//

import AppFeature
import Foundation
import ManifestInstallerService
import MessageDatabaseListener
import ExtensionMessageBus
import SwiftUI
import Utilities
import XPCSupport

let logger = Logger.for(category: "ViewModel")

final class ViewModel: ObservableObject {
    @Published var messages = [Message]()
    @Published var databaseFolder: URL? {
        didSet {
            guard let databaseFolder else { return }
            setupListner(for: databaseFolder.appending(path: "chat.db", directoryHint: .notDirectory))
        }
    }

    @Published var error: (any Error)? = nil

    private(set) var listener: MessageDatabaseListener?
    private let bus = ExtensionMessageBus()

    private let controller = XPCService<ManifestInstallerServiceProtocol>(
        connection: NSXPCConnection(serviceName: "me.foureyes.Twofy.ManifestInstaller"),
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

    func setupListner(for path: URL) {
        do {
            listener = try MessageDatabaseListener(path: path)
            controller.setup { error in
                logger.error("got error from XPC service \(error)")
            }
            controller.service?.install(for: NativeMessageSource.edge.rawValue, with: { error in
                if let installerError = error as? ManifestInstallationError {
                    logger.error("Installer Error \(installerError)")
                }
            })
            error = nil
        } catch let error {
            self.error = error
        }
    }

    func send(code: String) {
        bus.send(ExtensionMessage.code(code).actionJSON)
    }

    private func startFindingCodes() {
        guard let listener else { return }
        stopFindingCodes()

        try! bus.start()

        findMessagesTask = Task {
            for try await messages in listener.stream {
                Task { @MainActor in
                    self.messages = messages.filter({ $0.extractedCode() != nil })
                }
            }
        }

        listener.start(lookback: .days(30))
    }

    private func stopFindingCodes() {
        bus.stop()
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
