import AppFeature
import Dependencies
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
import SwiftUI

let logger = Logger.for(category: "App")

final class AppModel: ObservableObject {
    @Dependency(\.settings) var settings

    @Published private(set) var codesViewModel: CodesViewModel?

    @Published var databaseFolder: URL? {
        didSet {
            guard let databaseFolder else { return }
            setupListener(for: databaseFolder.appending(path: "chat.db", directoryHint: .notDirectory))
        }
    }

    @Published var error: (any Error)? = nil
    
    private let manifestInstaller = XPCService<ManifestInstallerServiceProtocol>(
        connection: NSXPCConnection(serviceName: .manifestInstaller),
        interface: NSXPCInterface(with: ManifestInstallerServiceProtocol.self)
    )

    init(codesViewModel: CodesViewModel? = nil, databaseFolder: URL? = nil, error: (any Error)? = nil) {
        self.codesViewModel = codesViewModel
        self.databaseFolder = databaseFolder
        self.error = error
    }

    func setupListener(for path: URL) {
        do {
            codesViewModel = try CodesViewModel(databasePath: path)
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
}

extension AppModel {
    static func stub() -> AppModel {
        let model = AppModel()

        return model
    }
}
