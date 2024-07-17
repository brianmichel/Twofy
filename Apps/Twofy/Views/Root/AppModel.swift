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
    @Published private(set) var settings = SettingsModel()
    @Published private(set) var codesViewModel: CodesViewModel?
    @Published private(set) var onboarding = OnboardingViewModel()
    

    @Published var databaseFolder: URL? {
        didSet {
            guard let databaseFolder else { return }
            setupListener(for: databaseFolder.appending(path: "chat.db", directoryHint: .notDirectory))
        }
    }

    @Published var error: (any Error)? = nil

    init(codesViewModel: CodesViewModel? = nil, databaseFolder: URL? = nil, error: (any Error)? = nil) {
        self.codesViewModel = codesViewModel
        self.databaseFolder = databaseFolder
        self.error = error
    }

    func setupListener(for path: URL) {
        do {
            codesViewModel = try CodesViewModel(databasePath: path)
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
