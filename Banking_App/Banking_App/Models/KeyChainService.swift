//
//  KeyChainService.swift
//  Banking_App
//
//  Created by Mahi on 15/10/25.
//

import Foundation
import Security

class KeychainService {
    static func save(email: String, password: String) {
        let data = "\(email):\(password)".data(using: .utf8)!
        let query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrAccount: email,
                     kSecValueData: data] as CFDictionary
        SecItemDelete(query)   
        SecItemAdd(query, nil)
    }

    static func load(email: String) -> (String, String)? {
        let query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrAccount: email,
                     kSecReturnData: true,
                     kSecMatchLimit: kSecMatchLimitOne] as CFDictionary

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query, &dataTypeRef)
        if status == errSecSuccess,
           let data = dataTypeRef as? Data,
           let str = String(data: data, encoding: .utf8) {
            let parts = str.split(separator: ":")
            if parts.count == 2 {
                return (String(parts[0]), String(parts[1]))
            }
        }
        return nil
    }
}


