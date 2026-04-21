//
//  DetailView.swift
//  Project-Idea
//
//  Created by Tom Brophy on 21/04/2026.
//

import SwiftUI
import LocalAuthentication

struct DetailView: View {
    let item: Item

    @State private var decryptedData: String?
    @State private var isUnlocked = false
    @State private var showingError = false

    var body: some View {
        VStack(spacing: 25) {
            Image(systemName: isUnlocked ? "lock.open.fill" : "lock.fill")
                .font(.system(size: 60))
                .foregroundColor(isUnlocked ? .green : .blue)
                .padding(.top, 40)

            Text(item.title)
                .font(.largeTitle)
                .bold()

            if isUnlocked {
                VStack(alignment: .leading, spacing: 15) {
                    if let data = decryptedData {
                        Text(data)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(12)
                            .textSelection(.enabled)
                    }
                }
                .padding()
            } else {
                Text("This information is encrypted")
                    .foregroundColor(.gray)

                Button(action: authenticate) {
                    Label("Reveal Sensitive Data", systemImage: "faceid")
                        .padding()
                }
                .buttonStyle(.borderedProminent)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Account Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Access your secure vault") { success, authenticationError in
                if success {
                    decrypt()
                } else {
                    print("Authentication failed")
                }
            }
        } else {
            decrypt()
        }
    }

    func decrypt() {
        let key = KeychainManager.getOrCreateMasterKey()

        if let decrypted = EncryptionManager.decrypt(item.secureData, key: key) {
            DispatchQueue.main.async {
                self.decryptedData = decrypted
                self.isUnlocked = true
            }
        }
    }
}
