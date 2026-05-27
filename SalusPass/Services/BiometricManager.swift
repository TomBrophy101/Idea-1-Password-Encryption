//
//  BiometricManager.swift
//  
//
//  Created by Tom Brophy on 10/03/2026.
// This for the authentication of the user to allow them to access their data.

import Foundation
import LocalAuthentication

struct BiometricManager {

    static func authenticateUser(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Access to your secure data is required."

            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in DispatchQueue.main.async {
                    completion(success)
                }
            }
        } else {
            print("Biometrics not available: \(error?.localizedDescription ?? "Unknown error")")
            DispatchQueue.main.async {
                completion(false)
            }
        }
    }
}
