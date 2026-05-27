//
//  PasswordGeneratorService.swift
//  Project-Idea
//
//  Created by Tom Brophy on 22/04/2026.
//  This is the service to create passwords.

import Foundation

struct PasswordGeneratorService {
    static func generate(length: Int = 16, includeSymbols: Bool = true, includeNumbers: Bool = true) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let digits = "0123456789"
        let symbols = "!€@£#$%^&*()-_=+[]{}|;:,.<>?/\\"

        var characterSet = letters
        if includeNumbers {
            characterSet += digits
        }

        if includeSymbols {
            characterSet += symbols
        }

        return String((0..<length).map {_ in
            characterSet.randomElement() ?? "x"
        })
    }
}
