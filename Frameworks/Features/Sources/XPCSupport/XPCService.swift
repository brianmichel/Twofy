import Foundation

public class XPCService<T> {
    public let connection: NSXPCConnection
    public let interface: NSXPCInterface
    public private(set) var service: T?

    public init(
        connection: NSXPCConnection,
        interface: NSXPCInterface
    ) {
        self.connection = connection
        self.interface = interface
    }

    deinit {
        connection.invalidate()
    }

    public func setup(errorHandler: @escaping ((Error) -> Void)) {
        connection.remoteObjectInterface = interface

        connection.interruptionHandler = {
            errorHandler(XPCError.connectionInterrupted)
        }

        connection.invalidationHandler = {
            errorHandler(XPCError.connectionInvalidated)
        }

        connection.resume()

        let remoteObjectProxy = connection.remoteObjectProxyWithErrorHandler(errorHandler)

        guard let xpcService = remoteObjectProxy as? T else {
            errorHandler(XPCError.connectionFailure("Unable to set up XPC connection to \(connection)"))
            return
        }

        service = xpcService
    }
}

extension XPCService {
    public enum XPCError: Error {
        case connectionInterrupted
        case connectionInvalidated
        case connectionFailure(String)
    }
}
