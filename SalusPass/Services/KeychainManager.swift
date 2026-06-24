//
//  KeychainManager.swift
//  SalusPass
//
//  Created by Tom Brophy on 10/03/2026.
//  This is to create an encryption key for the account in the program.

import Foundation
import Security
import CryptoKit

struct KeychainManager {
    private static let keyTag = "saluspass"

    static func getOrCreateMasterKey() -> SymmetricKey {
        if let existingKeyData = loadData(key: keyTag) {
            if existingKeyData.count == 32 {
                return SymmetricKey(data: existingKeyData)
            } else {
                deleteData(key: keyTag)
            }
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

    private static func deleteData(key: String) {
        let query = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ] as [String: Any]
        SecItemDelete(query as CFDictionary)
    }
}
