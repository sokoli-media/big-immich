//
//  KeychainHelper.swift
//  BigImmich
//
//  Created by Maciej Płoński on 19/12/2025.
//

import Foundation
import Security

class KeychainHelper {
    static func saveImmichAPIAuthMethod(method: ImmichAPIAuthMethod) -> Bool {
        return save(method.rawValue, forKey: "immichAPIAuthMethod")
    }

    static func loadImmichAPIAuthMethod() -> ImmichAPIAuthMethod? {
        if let method = load(forKey: "immichAPIAuthMethod") {
            return ImmichAPIAuthMethod(rawValue: method)
        } else {
            return nil
        }
    }

    static func saveImmichURL(url: String) -> Bool {
        return save(url, forKey: "immichURL")
    }

    static func loadImmichURL() -> String? {
        let value = load(forKey: "immichURL")

        if value == "" {
            return nil
        }
        return value
    }

    static func saveImmichAuthEmail(email: String) -> Bool {
        return save(email, forKey: "immichAuthEmail")
    }

    static func loadImmichAuthEmail() -> String? {
        let value = load(forKey: "immichAuthEmail")

        if value == "" {
            return nil
        }
        return value
    }

    static func saveImmichAuthPassword(password: String) -> Bool {
        return save(password, forKey: "immichAuthPassword")
    }

    static func loadImmichAuthPassword() -> String? {
        let value = load(forKey: "immichAuthPassword")

        if value == "" {
            return nil
        }
        return value
    }

    static func saveImmichAPIKey(key: String) -> Bool {
        return save(key, forKey: "immichAuthAPIKey")
    }

    static func loadImmichAPIKey() -> String? {
        let value = load(forKey: "immichAuthAPIKey")

        if value == "" {
            return nil
        }
        return value
    }

    static func save(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }

        // Delete existing item if present
        delete(forKey: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked,
        ]

        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }

    static func load(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess,
            let data = result as? Data,
            let value = String(data: data, encoding: .utf8)
        {
            return value
        }

        return nil
    }

    static func delete(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(query as CFDictionary)
    }
}
