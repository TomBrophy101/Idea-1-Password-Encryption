//
//  TwoFactorService.swift
//  
//
//  Created by Tom Brophy on 10/03/2026.
//  This is the service to implement two factor authentication.

import Foundation

struct TwoFactorService {
    static func generateCode() -> (raw: String, formatted: String) {
        let code = Int.random(in : 100000...999999)
        let raw = String(code)

        var formatted = raw
        let index = formatted.index(formatted.startIndex, offsetBy: 3)
        formatted.insert(" ", at: index)

        return (raw, formatted)
    }

    static func validate(_ input: String, against expected: String) -> Bool {
        let cleanInput = input.replacingOccurrences(of: " ", with: "")
        let cleanExpected = expected.replacingOccurrences(of: " ", with: "")
        return cleanInput == cleanExpected && !cleanInput.isEmpty
    }
}
