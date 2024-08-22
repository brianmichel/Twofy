import Foundation
import ManifestInstallerService
import SwiftyXPC

@main
final class ManifestInstallerXPCService {
    private enum Constants {
        static let codeSigningRequirement: String = {
        #if DEBUG
            #"identifier "me.foureyes.Twofy""#
        #else
            #"identifier "me.foureyes.Twofy" and anchor apple generic"#
        #endif
        }()
    }

    static func main() -> Void {
        do {
            let service = ManifestInstallerService()

            let listener = try XPCListener(type: .service, codeSigningRequirement: Constants.codeSigningRequirement)
            listener.setMessageHandler(name: ManifestInstallerService.Commands.installManifest, handler: service.install)
            listener.setMessageHandler(name: ManifestInstallerService.Commands.findNativeMessageSources, handler: service.findSources)
            listener.activate()
            fatalError("If reached the listener failed to activate for ManifestInstallerXPCService")
        } catch {
            fatalError("Unable to start ManifestInstallerXPCService: \(error)")
        }
    }
}
