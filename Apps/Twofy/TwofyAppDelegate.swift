import AppKit
import Foundation
import Utilities

private let logger = Logger.for(category: "AppDelegate")

final class TwofyAppDelegate: NSObject, NSApplicationDelegate {
    let viewModel = ViewModel()
    func applicationWillFinishLaunching(_ notification: Notification) {
        do {
            try viewModel.loginItem.register()
        } catch {
            logger.error("Error registering loginItem: \(error.localizedDescription)")
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        do {
            try viewModel.loginItem.unregister()
        } catch {
            logger.error("Error unregistering loginItem: \(error.localizedDescription)")
        }
    }
}
