//
//  Project_IdeaApp.swift
//  Project-Idea
//
//  Created by Tom Brophy on 10/03/2026.
//  This is the lock screen of the program.

import SwiftUI
import SwiftData

@main
struct Project_IdeaApp: App {
    @Environment(\.scenePhase) private var scenePhase
    

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @State private var hasFinishedSplash = false
    @State private var isUnlocked = false
    @State private var showPasswordFallback = false

    @State private var isEnteringPassword = false

    @State private var enteredPassword = ""
    @State private var showIncorrectPasswordMessage = false

    private let correctMasterPassword = "Brophs101!"

    var body: some Scene {
        WindowGroup {
            //This is the overall lock screen of the app itself.
            let isUITesting = ProcessInfo.processInfo.arguments.contains("-uitesting")
            Group {
                if !hasFinishedSplash && !isUITesting {
                    SplashView(isFinished: $hasFinishedSplash)
                } else  if !isUnlocked && !isUITesting {
                    VStack(spacing: 20) {
                        Image(systemName: "lock.shield")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)

                        Text("Program Locked")
                            .font(.headline)

                        //This is the main method of entering the app.
                        Button("Unlock with Face ID / Passcode") {
                            tryToUnlock()
                        }
                        .buttonStyle(.borderedProminent)

                        if showPasswordFallback {
                            Divider().frame(width: 200).padding()

                            //If the user's face ID doesn't work or they don't know their passcode, they have to enter their master password
                            Text("Forget Device Passcode?")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            if !isEnteringPassword {
                                Button("Enter Master Password") {
                                    withAnimation {
                                        isEnteringPassword = true
                                    }
                                }
                                .buttonStyle(.bordered)
                                .padding(.top, 10)
                            } else {
                                VStack(spacing: 15) {
                                    SecureField("Master Password", text: $enteredPassword)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(maxWidth: 250)
                                        .onSubmit {
                                            verifyPassword()
                                        }

                                    HStack(spacing: 20) {
                                        Button("Cancel") {
                                            withAnimation {
                                                isEnteringPassword = false
                                                showIncorrectPasswordMessage = false
                                                enteredPassword = ""
                                            }
                                        }
                                        .foregroundColor(.secondary)

                                        Button("Unlock") {
                                            verifyPassword()
                                        }
                                        .buttonStyle(.borderedProminent)
                                        .tint(.blue)
                                    }
                                    // This will show when the user enter a wrong password.
                                    if showIncorrectPasswordMessage {
                                        Text("Incorrect password. Try again.")
                                            .foregroundColor(.red)
                                            .font(.caption)
                                    }
                                }
                                .padding(.top, 20)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                    }
                    // .onAppear {
                    //    if !isUnlocked {
                    //        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    //            tryToUnlock()
                    //        }
                    //    }
                    //}
                } else {
                    ContentView(onLock: {
                        if !isUITesting {
                            isUnlocked = false
                        }
                    })
                    .transition(AnyTransition.move(edge: .bottom))
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .background {
                    isUnlocked = false
                    showPasswordFallback = false
                    isEnteringPassword = false
                    enteredPassword = ""
                    showIncorrectPasswordMessage = false
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }

    private func tryToUnlock() {
        BiometricManager.authenticateUser { success in
            DispatchQueue.main.async {
                if success {
                    isUnlocked = true
                } else {
                    showPasswordFallback = true
                }
            }
        }
    }

    private func verifyPassword() {
        if enteredPassword == correctMasterPassword {
            withAnimation {
                isUnlocked = true
            }
            enteredPassword = ""
            showIncorrectPasswordMessage = false
            isEnteringPassword = false
            showPasswordFallback = false
        } else {
            withAnimation {
                showIncorrectPasswordMessage = true
            }
            enteredPassword = ""
        }
    }
}
