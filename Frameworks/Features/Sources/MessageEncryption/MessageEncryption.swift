import Foundation
import KeychainAccess
import Sodium

public enum MessageEncryptorError: Error {
    case unableToSealMessage
    case unableToOpenMessage
}

/// A simple struct to allow for easy encryption & decrypted on data blobs
/// using a shared key which gets stored in the shared keychain group.
public struct MessageEncryptor {
    public enum Keys {
        public static let service = "me.foureyes.Twofy.message-encryption"
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

        var keychain = Keychain(service: Keys.service, accessGroup: Keys.group)
        keychain = keychain.synchronizable(true)
        keychain[data: Keys.identifier] = Data(secretKey)

        return secretKey
    }

    private static func getEncryptionKey() -> Data? {
        var keychain = Keychain(service: Keys.service, accessGroup: Keys.group)
        keychain = keychain.synchronizable(true)
        return keychain[data: Keys.identifier]
    }

    /// Encrypt a piece of data using the shared secret key.
    ///
    /// - parameter data: The data that should be encrypted.
    /// - returns: The encrypted data.
    /// - throws: `MessageEncryptorError.unableToSealMessage` if no bytes are produced by the sealing process.
    public func encrypt(_ data: Data) throws -> Data {
        let sodium = Sodium()
        let dataArray = [UInt8](data)
        guard let bytes: Bytes = sodium.secretBox.seal(message: dataArray, secretKey: secretKey) else {
            throw MessageEncryptorError.unableToSealMessage
        }

        return Data(bytes)
    }

    /// Decryptes a piece of data using the shared secret key.
    ///
    /// - parameter data: The data that should be decrypted.
    /// - returns: The decrypted data.
    /// - throws: `MessageEncryptorError.unableToopenMessage` if no bytes are produced by the opening process.
    public func decrypt(_ data: Data) throws -> Data {
        let sodium = Sodium()
        let dataArray = [UInt8](data)
        guard let bytes: Bytes = sodium.secretBox.open(nonceAndAuthenticatedCipherText: dataArray, secretKey: secretKey) else {
            throw MessageEncryptorError.unableToOpenMessage
        }

        return Data(bytes)
    }
}
