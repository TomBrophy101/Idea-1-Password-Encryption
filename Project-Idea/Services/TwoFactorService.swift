//
//  TwoFactorService.swift
//  
//
//  Created by Tom Brophy on 10/03/2026.
//
import Foundation

struct TwoFactorService {
    static func generateCode() -> String {
        let code = Int.random(in : 100000...999999)
        let codeString = String(code)

        let index = codeString.index(codeString.startIndex, offsetBy: 3)
        var formatted = codeString
        formatted.insert(" ", at: index)

        return formatted
    }
}
