import Foundation

@objc public protocol ServiceBrokerServiceProtocol {
    func registerMainApplication(with reply: @escaping (NSXPCListenerEndpoint) -> Void)
    func registerBrowserSupport(endpoint: NSXPCListenerEndpoint)
}
