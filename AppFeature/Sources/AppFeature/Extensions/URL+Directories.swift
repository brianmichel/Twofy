import Foundation

extension URL {
    /// Returns the real home directory even when sandboxed.
    public static var realHomeDirectory: URL {
        URL(fileURLWithFileSystemRepresentation: getpwuid(getuid()).pointee.pw_dir, isDirectory: true, relativeTo: nil)
    }

    /// Returns `~/Library/Messages`
    public static var messageDatabasePath: URL {
        .realHomeDirectory
        .appending(path: "Library", directoryHint: .isDirectory)
        .appending(path: "Messages", directoryHint: .isDirectory)
    }
}
