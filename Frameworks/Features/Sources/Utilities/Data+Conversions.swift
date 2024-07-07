import Foundation

extension Data {
    public func toUInt32() -> UInt32? {
        guard self.count >= 4 else { return nil }
        return self.withUnsafeBytes { $0.load(as: UInt32.self) }
    }
}
