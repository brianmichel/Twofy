//
//  File.swift
//  
//
//  Created by Brian Michel on 6/27/24.
//

import Foundation

public final class ExtensionMessageBus {
    private var task: Task<Void, (any Error)>?

    private let input = FileHandle.standardInput
    private let output = FileHandle.standardOutput

    public init() {}

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

    private func receive() throws -> [String: Any]? {
        guard let lengthData = try input.read(upToCount: 4) else {
            return nil
        }

        let messageLength = lengthData.withUnsafeBytes { $0.load(as: UInt32.self) }
        guard let messageData = try input.read(upToCount: Int(messageLength)) else {
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

    private func send(_ message: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: message, options: [])
            let messageLength = UInt32(jsonData.count)
            let headerData = withUnsafeBytes(of: messageLength.bigEndian) { Data($0) }

            try output.write(contentsOf: headerData)
            try output.write(contentsOf: jsonData)
        } catch {
            print("Error sending message: \(error)")
        }
    }
}
