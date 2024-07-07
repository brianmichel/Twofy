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
            let inputJSONObject = action.actionJSON
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

        let inputJSONObject = ExtensionMessage.pollingTimeout.actionJSON

        let sut = ExtensionMessageBus(input: input, output: output)
        sut.send(inputJSONObject)

        let receivedJSONObject = try XCTUnwrap(sut.receive())

        let inputData = try XCTUnwrap(JSONSerialization.data(withJSONObject: inputJSONObject))
        let receivedData = try XCTUnwrap(JSONSerialization.data(withJSONObject: receivedJSONObject))

        XCTAssertEqual(inputData, receivedData)
    }
}
