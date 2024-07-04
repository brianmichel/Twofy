import Foundation
import ManifestInstallerService

class ServiceDelegate: NSObject, NSXPCListenerDelegate {
        func listener(_ listener: NSXPCListener, shouldAcceptNewConnection newConnection: NSXPCConnection) -> Bool {
        newConnection.exportedInterface = NSXPCInterface(with: ManifestInstallerServiceProtocol.self)

        let exportedObject = ManifestInstallerService()
        newConnection.exportedObject = exportedObject
        
        newConnection.resume()

        return true
    }
}

let delegate = ServiceDelegate()

let listener = NSXPCListener.service()
#if !DEBUG
// TODO: Figure out how to setup this requirement correctly
listener.setConnectionCodeSigningRequirement("anchor apple and identifier me.foureyes.Twofy")
#endif
listener.delegate = delegate

listener.resume()
