import Foundation
import KeychainAccess
import Sodium

public enum MessageEncryptorError: Error {
    case unableToSealMessage
    case unableToOpenMessage
}

public struct MessageEncryptor {
    public enum Keys {
        public static let service = "me.foureyes.message-encryption"
        public static let group = "YN24FFRTC8.me.foureyes.Twofy"
        public static let identifier = "message-encryption-key"
    }

    private let secretKey: SecretBox.Key

    public init() {
        if let key = Self.getEncryptionKey() {
            secretKey = [UInt8](key)
        } else {
            secretKey = Self.setupEncryptionKey()
        }
    }

    private static func setupEncryptionKey() -> SecretBox.Key {
        let sodium = Sodium()
        let secretKey = sodium.secretBox.key()

        let keychain = Keychain(service: Keys.service, accessGroup: Keys.group)
        keychain[data: Keys.identifier] = Data(secretKey)

        return secretKey
    }

    private static func getEncryptionKey() -> Data? {
        let keychain = Keychain(service: Keys.service, accessGroup: Keys.group)
        return keychain[data: Keys.identifier]
    }

    public func encrypt(_ data: Data) throws -> Data {
        let sodium = Sodium()
        let dataArray = [UInt8](data)
        guard let bytes: Bytes = sodium.secretBox.seal(message: dataArray, secretKey: secretKey) else {
            throw MessageEncryptorError.unableToSealMessage
        }

        return Data(bytes)
    }

    public func decrypt(_ data: Data) throws -> Data {
        let sodium = Sodium()
        let dataArray = [UInt8](data)
        guard let bytes: Bytes = sodium.secretBox.open(nonceAndAuthenticatedCipherText: dataArray, secretKey: secretKey) else {
            throw MessageEncryptorError.unableToOpenMessage
        }

        return Data(bytes)
    }
}
