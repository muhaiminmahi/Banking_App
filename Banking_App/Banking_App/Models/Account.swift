//
//  Account.swift
//  Banking_App
//
//  Created by Mahi on 15/10/25.
//

import Foundation

enum AccountType: String {
    case checking = "Checking"
    case savings = "Savings"
}

struct Account {
    let id: String
    let type: AccountType
    var balance: Double
}

