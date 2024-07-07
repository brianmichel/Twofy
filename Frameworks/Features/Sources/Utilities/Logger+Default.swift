@_exported import OSLog

extension Logger {
    public static func `for`(subsystem: String = "me.foureyes.twofy", category: String) -> Logger {
        Logger(subsystem: subsystem, category: category)
    }
}
