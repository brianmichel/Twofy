import Cocoa
import DistributedNotificationIPC
import ExtensionMessageBus
import Utilities

let logger = Logger.for(subsystem: "me.foureyes.Twofy.BrowserSupport", category: "AppDelegate")

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private let listener = NSXPCListener.anonymous()

    @IBOutlet var window: NSWindow!

    private let bus = ExtensionMessageBus()

    override init() {
        logger.error("Setting up BrowserSupport application")
        super.init()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        try! bus.start()
        BrowserSupportIPCNotificationMessage.receive { [weak self] message in
            guard let self else { return }
            logger.debug("Received distributed ipc notification with action \(message.id)")

            switch message.action {
            case let .foundCode(code):
                bus.send(.code(code))
            }
        }
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}

