//
//  PhoneAuthService.swift
//  SalusPass
//
//  Created by Tom Brophy on 02/06/2026.
//

import Foundation

struct PhoneAuthService {

    static func sendCode(to phoneNumber: String) -> (raw: String, formatted: String) {
        let code = Int.random(in: 100000...999999)
        let raw = String(code)

        var formatted = raw
        let index = formatted.index(formatted.startIndex, offsetBy: 3)
        formatted.insert(" ", at: index)

        print("DEBUG [PhoneAuth]: Sent SMS verification code [\(formatted)] to target: \(phoneNumber)")

        return (raw, formatted)
    }

    static func validate(_ input: String, against expected: String) -> Bool {
        let cleanInput = input.replacingOccurrences(of: " ", with: "")
        let cleanExpected = expected.replacingOccurrences(of: " ", with: "")

        guard cleanInput.count == 6 && cleanExpected.count == 6 else {
            return false
        }

        return cleanInput == cleanExpected
    }
}
