import Foundation
import SwiftUI

final class SettingsModel: ObservableObject {
    enum ID: String {
        case pollingInterval
        case startOnLogin
        case lookbackWindow
    }

    @AppStorage(ID.pollingInterval.rawValue) var pollingInterval: Double = 10
    @AppStorage(ID.startOnLogin.rawValue) var startOnLogin = false
    @AppStorage(ID.lookbackWindow.rawValue) var lookbackWindow: Double = 2
}
