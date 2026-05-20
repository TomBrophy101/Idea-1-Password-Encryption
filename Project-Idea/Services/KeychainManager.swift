//
//  KeychainManager.swift
//  
//
//  Created by Tom Brophy on 10/03/2026.
//  This is to create an encryption key for the account in the program.

import Foundation
import Security
import CryptoKit

struct KeychainManager {
    static func getOrCreateMasterKey() -> SymmetricKey {
        let keyTag = "com.projectidea.masterKey"

        if let existingKeyData = loadData(key: keyTag) {
            return SymmetricKey(data: existingKeyData)
        }

        let newKey = SymmetricKey(size: .bits256)
        let newKeyData = newKey.withUnsafeBytes { Data($0) }

        saveData(key: keyTag, data: newKeyData)
        return newKey
    }
    static func save(key: String, data: String) {
        saveData(key: key, data: Data(data.utf8))
    }

    static func load(key: String) -> String? {
        if let data = loadData(key: key) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    private static func saveData(key: String, data: Data) {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ] as [String: Any]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private static func loadData(key: String) -> Data? {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ] as [String: Any]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        return (status == errSecSuccess) ? (dataTypeRef as? Data) : nil
    }
}
