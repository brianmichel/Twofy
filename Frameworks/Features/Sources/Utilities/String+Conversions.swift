import Foundation

extension String {
    public static func describing<T: CustomStringConvertible>(_ thing: T) -> String {
        .init(describing: thing)
    }
}
