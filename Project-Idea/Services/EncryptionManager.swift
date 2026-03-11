//
//  EncryptionManager.swift
//
//
//  Created by Tom Brophy on 10/03/2026.
//
import Foundation
import CryptoKit

struct EncryptionManager {
    static func hashPassword(_ input: String) -> String {
        let data = Data(input.utf8)
        let hashed = SHA256.hash(data: data)

        return hashed.compactMap { String(format: "%02x", $0)}.joined()
    }
}
