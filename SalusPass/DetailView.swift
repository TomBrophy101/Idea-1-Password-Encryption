//
//  DetailView.swift
//  SalusPass
//
//  Created by Tom Brophy on 21/04/2026.
//  This is the screen for the list of saved accounts.

import SwiftUI
import LocalAuthentication

struct DetailView: View {
    let item: Item

    @State private var email = ""
    @State private var password = ""

    @State private var isUnlocked = false
    @State private var isPasswordVisible = false
    @State private var showingError = false
    @State private var showCopiedBanner = false

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 25) {
                //This is to open up the email and password and they have to use Face ID to view them
                Image(systemName: isUnlocked ? "lock.open.fill" : "lock.fill")
                    .font(.system(size: 60))
                    .foregroundColor(isUnlocked ? .green : .red)
                    .padding(.top, 40)

                Text(item.title)
                    .font(.largeTitle)
                    .bold()

                if isUnlocked {
                    VStack(spacing: 20) {
                        credentialRow(label: "Email", value: email)
                        credentialRow(label: "Password", value: password, isSensitive: true)

                        Button(action: openSystemPasswordsApp) {
                            Label("Open iOS Passwords System", systemImage: "key.fill")                                .font(.footnote)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                        }
                        .padding(.top)
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

            if showCopiedBanner {
                Text("Copied to Clipboard")
                    .font(.subheadline.bold())
                    .padding(10)
                    .background(Color.black.opacity(0.8))
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 20)
            }
        }
        .navigationTitle("Account Details")
//        .alert("Authentication Failed", isPresented: $showingError) {
//            Button("OK", role: .cancel) { }
//        } message: {
//            Text("Could not verify your identity. Please try again.")
//        }
        //.onAppear {
        //    if !isUnlocked {
        //        authenticate()
        //    }
        //}
    }

    //This is to continue to have the password be only visible when the user presses the eye icon.
    @ViewBuilder
    private func credentialRow(label: String, value: String, isSensitive: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label).font(.caption).foregroundColor(.secondary)
            HStack {
                if isSensitive && !isPasswordVisible {
                    Text("••••••••••••")
                } else {
                    Text(value).font(.system(.body, design: .monospaced))
                }

                Spacer()

                //This is to continue to have the password be only visible when the user presses the eye icon.
                if isSensitive {
                    Button { isPasswordVisible.toggle() } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                    }
                    .padding(.trailing, 8)
                }
                if !isSensitive || isPasswordVisible {
                    Button {
                       copyToClipboard(text: value)
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(10)
        }
    }

    private func copyToClipboard(text: String) {

        guard !text.isEmpty else {
            return
        }

        UIPasteboard.general.string = text

        DispatchQueue.main.async {
            let generator = UINotificationFeedbackGenerator()
            generator.prepare()
            generator.notificationOccurred(.success)

            withAnimation {
                showCopiedBanner = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation {
                    showCopiedBanner = false
                }
            }
        }
    }

    private func authenticate() {
        BiometricManager.authenticateUser { success in
            DispatchQueue.main.async {
                if success {
                    decrypt()
                } else {
                    self.showingError = true
                }
            }
        }
    }

    private func decrypt() {
        let key = KeychainManager.getOrCreateMasterKey()

        if let decrypted = EncryptionManager.decrypt(item.secureData, key: key) {
            DispatchQueue.main.async {
                let lines = decrypted.components(separatedBy: "\n")
                for line in lines {
                    if line.hasPrefix("Email: ") {
                        self.email = line.replacingOccurrences(of: "Email: ", with: "")
                    } else if line.hasPrefix("Password: ") {
                        self.password = line.replacingOccurrences(of: "Password: ", with: "")
                    }
                }
                self.isUnlocked = true
            }
        }
    }

    private func openSystemPasswordsApp() {
        if let url = URL(string: "App-Prefs:root=PASSWORDS") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                if let fallbackUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(fallbackUrl, options: [:], completionHandler: nil)
                }
            }
        }
    }

}
