import Foundation
import Utilities

public final class ExtensionMessageBus {
    private var task: Task<Void, (any Error)>?

    private let input: FileHandle
    private let output: FileHandle

    public init(input: FileHandle = .standardInput, output: FileHandle = .standardOutput) {
        self.input = input
        self.output = output
    }

    public func start() throws {
        stop()
        task = Task {
            while !Task.isCancelled {
                guard let input = try receive() else {
                    break
                }

                // Process the input
                print("Received message: \(input)")

                // You can process the input here and send a response if needed
                let response = ["response": "Message received"]
                send(response)
            }
        }
    }

    public func stop() {
        task?.cancel()
        task = nil
    }

    internal func receive() throws -> [String: Any]? {
        guard let lengthData = try input.read(upToCount: .messageHeaderLength) else {
            return nil
        }

        guard  let messageLength = lengthData.toUInt32(), let messageData = try input.read(upToCount: Int(messageLength)) else {
            return nil
        }

        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: messageData, options: []) as? [String: Any] {
                return jsonObject
            }
        } catch {
            print("Error parsing JSON: \(error)")
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
            print("Error sending message: \(error)")
        }
    }
}
