//
//  LocalDataService.swift
//  Banking_App
//
//  Created by Mahi on 15/10/25.
//

import Foundation

class LocalDataService {
    static let shared = LocalDataService()
    private let usersKey = "users_credentials"
    private let lastUserKey = "last_logged_in"

    private init() {}
    
    func saveTransactions(_ transactions: [Transaction], for email: String) {
        let key = "transactions_\(email)"
        if let data = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func loadTransactions(for email: String) -> [Transaction] {
        let key = "transactions_\(email)"
        if let data = UserDefaults.standard.data(forKey: key),
           let txs = try? JSONDecoder().decode([Transaction].self, from: data) {
            return txs
        }
        return []
    }

    
    func saveBalance(_ balance: Double, for email: String) {
        let key = "balance_\(email)"  
        UserDefaults.standard.set(balance, forKey: key)
    }

    func loadBalance(for email: String) -> Double {
        let key = "balance_\(email)"
        return UserDefaults.standard.double(forKey: key)
    }



    func saveUser(email: String, password: String) {
        var dict = loadUsers()
        dict[email] = password
        UserDefaults.standard.set(dict, forKey: usersKey)
        saveLastUser(email: email)
    }

    func validateUser(email: String, password: String) -> Bool {
        let dict = loadUsers()
        return dict[email] == password
    }

    func saveLastUser(email: String) {
        UserDefaults.standard.set(email, forKey: "lastUser")
    }

    func getLastUser() -> String? {
        return UserDefaults.standard.string(forKey: "lastUser")
    }


    func loadUsers() -> [String: String] {
        return UserDefaults.standard.dictionary(forKey: usersKey) as? [String: String] ?? [:]
    }
}

