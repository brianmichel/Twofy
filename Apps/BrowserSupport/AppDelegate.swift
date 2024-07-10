//
//  AppDelegate.swift
//  BrowserSupport
//
//  Created by Brian Michel on 7/8/24.
//

import Cocoa
import BrowserSupportService
import ServiceBrokerService
import Utilities
import XPCSupport

let logger = Logger.for(subsystem: "me.foureyes.Twofy.BrowserSupport", category: "AppDelegate")

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSXPCListenerDelegate, BrowserSupportServiceProtocol {
    private let browserSupport: BrowserSupportService
    private let listener = NSXPCListener.anonymous()
    private let serviceBroker = XPCService<ServiceBrokerServiceProtocol>(
        connection: NSXPCConnection(machServiceName: "YN24FFRTC8.me.foureyes.Twofy.ServiceBroker"),
        interface: NSXPCInterface(with: ServiceBrokerServiceProtocol.self)
    )

    @IBOutlet var window: NSWindow!

    override init() {
        browserSupport = try! BrowserSupportService()
        logger.error("Setting up BrowserSupport application")
        super.init()
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
#if !DEBUG
        // TODO: Figure out how to setup this requirement correctly
        listener.setConnectionCodeSigningRequirement(#"identifier "me.foureyes.Twofy" and anchor apple generic"#)
#endif
        serviceBroker.setup { error in
            logger.error("Received error for service broker: \(error.localizedDescription)")
        }

        listener.delegate = self
        listener.resume()

        serviceBroker.service?.registerBrowserSupport(endpoint: listener.endpoint)
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    // MARK: - BrowserSupportServiceProtocol
    func send(code: String) async throws -> (any Error)? {
        return try await browserSupport.send(code: code)
    }

    func send(code: String, with reply: @escaping (((any Error)?) -> Void)) {
        browserSupport.send(code: code, with: reply)
    }

    // MARK: - NSXPCListenerDelegate
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: BrowserSupportServiceProtocol.self)
        newConnection.exportedObject = self
        newConnection.resume()

        return true
    }
}

