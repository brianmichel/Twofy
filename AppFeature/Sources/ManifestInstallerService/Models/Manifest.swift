import Foundation

struct Manifest: Codable {
    let name: String
    let description: String
    let path: String
    let type: String
    let allowedOrigins: [String]
}

extension Manifest {
    static var twofyBrowserSupport: Self {
        .init(
            name: "me.foureyes.twofy",
            description: "Twofy Browser Support",
            path: Bundle.main.bundlePath,
            type: "stdio",
            allowedOrigins: [])
    }
}
