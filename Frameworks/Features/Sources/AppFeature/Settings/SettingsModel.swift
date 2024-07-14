import Dependencies
import Foundation
import SwiftUI

extension DependencyValues {
    struct SettingsDependencyKey: DependencyKey {
        static var liveValue = SettingsModel()
    }

    public var settings: SettingsModel {
        get { self[SettingsDependencyKey.self] }
        set { self[SettingsDependencyKey.self] = newValue }
    }
}

public final class SettingsModel: ObservableObject {
    enum ID: String {
        case pollingInterval
        case startOnLogin
        case lookbackWindow
    }

    @AppStorage(ID.pollingInterval.rawValue) public var pollingInterval: Double = 10
    @AppStorage(ID.startOnLogin.rawValue) public var startOnLogin = false
    @AppStorage(ID.lookbackWindow.rawValue) public var lookbackWindow: Double = 2
}
