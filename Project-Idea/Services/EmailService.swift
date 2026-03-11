//
//  EmailService.swift
//  
//
//  Created by Tom Brophy on 10/03/2026.
//
import Foundation

struct EmailService {
    static func createRandomEmail() -> String {
        let characters = "abcdefghijklmnopqrstuvwxyz1234567890"
        let randomString = String((0..<10).map{ _ in characters.randomElement()!})

        return "\(randomString)@temp-vault.com"
    }
}
