import GRDB
import Foundation

public struct Message {
    public let id: Int64
    public let sender: String?
    public let service: String
    public let date: Date
    public let text: String

    public func extractedCode() -> String? {
        text.extractTwoFactorCodes().first
    }

    public func maskedCode() -> String {
        guard let code = extractedCode() else {
            return "···"
        }
        return Array(repeating: "·", count: code.count).joined()
    }
}

extension Message: FetchableRecord {
    public init(row: Row) throws {
        id = row["id"]
        sender = row["sender"]
        service = row["service"]
        date = row["message_date"]
        text = row["text"]
    }
}

extension Message {
    public static func stub(id: Int64, code: String) -> Message {
        .init(id: id, sender: "testing", service: "sms", date: .now, text: code)
    }
}

extension Message: Identifiable, Equatable {}

extension String {
    func extractTwoFactorCodes() -> [String] {
        // Define a regular expression pattern for a 3 to 8-digit 2FA code
        let pattern = "\\b\\d{3,8}\\b"

        do {
            // Create a regular expression object
            let regex = try NSRegularExpression(pattern: pattern, options: [])

            // Find matches in the text
            let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.utf8.count))

            // Extract the matching codes from the text
            let codes = matches.map { match -> String in
                let range = match.range
                if let swiftRange = Range(range, in: self) {
                    return String(self[swiftRange])
                }
                return ""
            }

            return codes
        } catch {
            // Handle errors in the regular expression
            print("Invalid regular expression")
            return []
        }
    }
}

