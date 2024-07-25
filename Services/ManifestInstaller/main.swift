import Foundation
import ManifestInstallerService

class ServiceDelegate: NSObject, NSXPCListenerDelegate {
    private enum Constants {
        static let codeSigningRequirement: String = {
            #if DEBUG
            #"identifier "me.foureyes.Twofy""#
            #else
            #"identifier "me.foureyes.Twofy" and anchor apple generic"#
            #endif
        }()
    }

    func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.setCodeSigningRequirement(Constants.codeSigningRequirement)
        newConnection.exportedInterface = NSXPCInterface(with: ManifestInstallerServiceProtocol.self)
        newConnection.exportedObject = ManifestInstallerService()
        newConnection.resume()

        return true
    }
}

let delegate = ServiceDelegate()

let listener = NSXPCListener.service()
listener.delegate = delegate

listener.resume()
