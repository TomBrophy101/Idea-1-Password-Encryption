//
//  EncryptionManager.swift
//
//
//  Created by Tom Brophy on 10/03/2026.
//  This is to manage the encryption keys of the program.

import Foundation
import CryptoKit

struct EncryptionManager {

    private static let salt = "Project-Idea-Secure-Salt-v1-992837465"

    static func hashPassword(_ input: String) -> String {
        let saltedInput = input + salt
        let data = Data(saltedInput.utf8)
        let hashed = SHA256.hash(data: data)

        return hashed.compactMap { String(format: "%02x", $0)}.joined()
    }

    static func encrypt(_ text: String, key: SymmetricKey) -> String? {
        let data = Data(text.utf8)
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined?.base64EncodedString()
        } catch {
            print("Encryption error: \(error.localizedDescription)")
            return nil
        }
    }

    static func decrypt(_ text: String, key: SymmetricKey) -> String? {
        guard let data = Data(base64Encoded: text) else { return nil }
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return String(data: decryptedData, encoding: .utf8)
        } catch {
            print("Decryption error: \(error.localizedDescription)")
            return nil
        }
    }
}
