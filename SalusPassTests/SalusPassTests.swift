//
//  Project_IdeaTests.swift
//  Project-IdeaTests
//
//  Created by Tom Brophy on 10/03/2026.
//

import Testing
import CryptoKit
import Foundation
@testable import Project_Idea

@MainActor
struct Project_IdeaTests {

    @Test func testEncryptionCycle() async throws {
        //let manager = EncryptionManager()
        let key = SymmetricKey(size: .bits256)
        let originalText = "Brophs101!"

        guard let encrypted = EncryptionManager.encrypt(originalText, key: key) else {
            Issue.record("Encryption failed to produce data")
            return
        }
        //#expect(encrypted != nil)
        #expect(encrypted != originalText)

        let decrypted = EncryptionManager.decrypt(encrypted, key: key)

        #expect(decrypted == originalText)
    }

    @Test func testEmailGenerationFormat() async throws {
        let email = EmailService.createRandomEmail()

        let emailPattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z-0-9.-]+\.[A-Za-z]{2,64}$"#
        let result = email.range(of: emailPattern, options: .regularExpression)

        #expect(result != nil, "Generated email '\(email)' is not a valid format")
    }

    @Test func testPasswordStrength() async throws {
        let length = 32
        let password = PasswordGeneratorService.generate(length: length)

        #expect(password.count == length)

        let uniqueChars = Set(password)
        #expect(uniqueChars.count > 1)
    }
}
