@testable import ExtensionMessageBus

import XCTest

final class ExtensionMessageBusTests: XCTestCase {
    func testWritingToMessageBusProducesValidJSON() throws {
        let pipe = Pipe()
        let output = pipe.fileHandleForWriting
        let input = pipe.fileHandleForReading

        let sut = ExtensionMessageBus(input: input, output: output)
        let actions: [ExtensionMessage] = [.code("22993"), .pollingTimeout, .unknown("Oops")]

        for action in actions {
            let inputJSONObject = action.json
            let inputJSONData = try JSONSerialization.data(withJSONObject: inputJSONObject)

            sut.send(inputJSONObject)

            let header = try XCTUnwrap(input.read(upToCount: .messageHeaderLength)?.toUInt32())
            XCTAssertEqual(header, UInt32(inputJSONData.count))

            let jsonData = try XCTUnwrap(input.read(upToCount: Int(header)))
            let json = try JSONSerialization.jsonObject(with: jsonData)

            XCTAssertNotNil(json)
        }
    }

    func testWritingAndReceivingProducesValidJSON() throws {
        let pipe = Pipe()
        let output = pipe.fileHandleForWriting
        let input = pipe.fileHandleForReading

        let inputJSONObject = ExtensionMessage.pollingTimeout.json

        let sut = ExtensionMessageBus(input: input, output: output)
        sut.send(inputJSONObject)

        let receivedJSONObject = try XCTUnwrap(sut.receive())

        let inputData = try XCTUnwrap(JSONSerialization.data(withJSONObject: inputJSONObject))
        let receivedData = try XCTUnwrap(JSONSerialization.data(withJSONObject: receivedJSONObject))

        XCTAssertEqual(inputData, receivedData)
    }

    func testMessagesAreAutomaticallyProcessedAndRepliedToWhenBusIsStarted() async throws {
        let pipe = Pipe()
        let output = pipe.fileHandleForWriting
        let input = pipe.fileHandleForReading

        let inputJSONObject = ExtensionMessage.code("2233").json

        let sut = ExtensionMessageBus(input: input, output: output)
        try sut.start()

        let expectation = expectation(forNotification: .NSFileHandleDataAvailable, object: input)

        sut.send(inputJSONObject)

        await fulfillment(of: [expectation], timeout: 2.0)

        let json = try XCTUnwrap(sut.receive())

        XCTAssertNotNil(json)
    }
}
