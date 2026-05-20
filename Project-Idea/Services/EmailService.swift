//
//  EmailService.swift
//  
//
//  Created by Tom Brophy on 10/03/2026.
//  This is the service to implement emails.

import Foundation

struct EmailService {

    private static let prefixes = ["user", "mail", "vault", "proxy", "hidden", "cheese", "mac", "x22", "x23", "x24", "x25", "x26"]

    private static let domains = ["temp-vault.com", "secure-mail.org", "privacy-shield.io", "ghost-inbox.net", "student.ncirl.ie", "gmail.com", "outlook.com", "icloud.com", "fastmail.com"]

    static func createRandomEmail() -> String {
        let prefix = prefixes.randomElement() ?? "user"

        let number = Int.random(in: 100000...999999)

        let domain = domains.randomElement() ?? "temp-vault.com"

        return "\(prefix)\(number)@\(domain)"
    }
}
