import Foundation
import Utilities

let logger = Logger.for(category: "ExtensionMessageBus")

public final class ExtensionMessageBus {
    private var task: Task<Void, (any Error)>?

    private let input: FileHandle
    private let output: FileHandle

    public init(input: FileHandle = .standardInput, output: FileHandle = .standardOutput) {
        self.input = input
        self.output = output
    }

    public func start() throws {
        logger.debug("Starting to listen for data...")
        stop()

        input.readabilityHandler = { [weak self] handle in
            guard let self else { return }
            logger.debug("Data available from readabilityHandler, attempting to process")

            guard let _ = try! receive() else {
                return
            }
        }
    }

    public func stop() {
        input.readabilityHandler = nil
    }

    public func send(_ message: ExtensionMessage) {
        send(message.json)
    }

    internal func receive() throws -> [String: Any]? {
        guard let lengthData = try input.read(upToCount: .messageHeaderLength) else {
            logger.debug("Exiting early, can't find data the length of the header...")
            return nil
        }

        guard  let messageLength = lengthData.toUInt32(), let messageData = try input.read(upToCount: Int(messageLength)) else {
            logger.debug("Exiting early, can't convert data length and read the correct sized data...")
            return nil
        }

        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: messageData, options: []) as? [String: Any] {
                return jsonObject
            }
        } catch {
            logger.error("Error parsing JSON: \(error)")
        }

        return nil
    }

    internal func send(_ message: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: message, options: [])
            let messageLength = UInt32(jsonData.count)
            let headerData = withUnsafeBytes(of: messageLength) { Data($0) }

            try output.write(contentsOf: headerData)
            try output.write(contentsOf: jsonData)
        } catch {
            logger.error("Error sending message: \(error)")
        }
    }
}
