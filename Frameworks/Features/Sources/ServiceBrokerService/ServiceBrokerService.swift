import Foundation

public class ServiceBrokerService: ServiceBrokerServiceProtocol {
    // TODO: This should probably use a lock to ensure thread safety.
    private var pendingReplies = [((NSXPCListenerEndpoint) -> Void)]()
    private var browserSupportEndpoint: NSXPCListenerEndpoint?

    public init() {}

    /// Stores pending replies to the main application and clears the queue if there's
    /// already a stored `browserSupportEndpoint`. The replies should be used to setup
    /// `BrowserSupportSerivce` connections in the main application.
    ///
    /// This should be called from the main application.
    public func registerMainApplication(with reply: @escaping (NSXPCListenerEndpoint) -> Void) {
        pendingReplies.append(reply)
        if let endpoint = browserSupportEndpoint {
            clearPendingMainApplicationReplies(with: endpoint)
        }
    }

    /// Stores the passed endpoint and clears any pending main application replies.
    ///
    /// This is typically called from the browser support application so that the
    /// main application knows how to communicate with it.
    public func registerBrowserSupport(endpoint: NSXPCListenerEndpoint) {
        browserSupportEndpoint = endpoint
        clearPendingMainApplicationReplies(with: endpoint)
    }

    private func clearPendingMainApplicationReplies(with endpoint: NSXPCListenerEndpoint) {
        for reply in pendingReplies {
            reply(endpoint)
        }
        pendingReplies.removeAll()
    }

}
