//
//  AppDelegate.swift
//  ServiceBroker
//
//  Created by Brian Michel on 7/9/24.
//

import Cocoa
import ServiceBrokerService
import Utilities

let logger = Logger.for(subsystem: "me.foureyes.Twofy.ServiceBroker", category: "AppDelegate")

@main
class AppDelegate: NSObject, NSApplicationDelegate, NSXPCListenerDelegate, ServiceBrokerServiceProtocol {
    private let broker = ServiceBrokerService()
    private let listener = NSXPCListener(machServiceName: Bundle.main.bundleIdentifier!)

    @IBOutlet var window: NSWindow!

    override init() {
        super.init()
        logger.info("Hello world!")
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
#if !DEBUG
        // TODO: Figure out how to setup this requirement correctly
        listener.setConnectionCodeSigningRequirement(#"identifier "me.foureyes.Twofy" and anchor apple generic"#)
#endif
        logger.info("Setting up listener for mach service")
        listener.delegate = self
        listener.resume()
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    // MARK: - ServiceBrokerServiceProtoocol
    func registerMainApplication(with reply: @escaping (NSXPCListenerEndpoint) -> Void) {
        logger.debug("ServiceBroker registering main application")
        broker.registerMainApplication(with: reply)
    }

    func registerBrowserSupport(endpoint: NSXPCListenerEndpoint) {
        logger.debug("ServiceBroker registering browser support endpoint")
        broker.registerBrowserSupport(endpoint: endpoint)
    }

    // MARK: - NSXPCListenerDelegate
    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: ServiceBrokerServiceProtocol.self)
        newConnection.exportedObject = self
        newConnection.resume()

        logger.debug("Accepting new listener for service broker to communicate with")

        return true
    }
}

