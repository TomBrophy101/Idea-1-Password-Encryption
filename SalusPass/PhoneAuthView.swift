//
//  PhoneAuthView.swift
//  SalusPass
//
//  Created by Tom Brophy on 02/06/2026.
//  This is when the user has to use their phone number to enter into the app.

import SwiftUI

struct PhoneAuthView: View {
    var onAuthSuccess: () -> Void

    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var isCodeSent = false
    @State private var errorMessage = ""

    @State private var expectedCodeRaw = ""
    @State private var isCodeCopied = false

    @FocusState private var isPhoneFocused: Bool
    @FocusState private var isCodeFocused: Bool

    private var isInputEmpty: Bool {
        isCodeSent ? verificationCode.isEmpty : phoneNumber.isEmpty
    }

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 12) {
                Image(systemName: isCodeSent ? "lock.shield.fill" : "phone.circle.fill")
                    .resizable()
                    .frame(width: 72, height: 72)
                    .foregroundColor(.blue)
                    .padding(.bottom, 4)

                Text(isCodeSent ? "Verify Your Number" : "Phone Authentication")
                    .font(.system(size: 24, design: .rounded))
                    .fontWeight(.heavy)
                    .tracking(0.5)
                    .foregroundColor(.blue)

                Text(isCodeSent ? "Enter the 6-digit code sent to \n\(phoneNumber)" : "Enter your phone number to receive a secure verification code.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                if isCodeSent {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Image(systemName: "message.fill")
                                    .foregroundColor(.blue)
                                Text("Messages • Just Now")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.semibold)
                            }
                            Text("SalusPass: Your verification code is \(expectedCodeRaw). Don't share it.")
                                .font(.caption)
                                .foregroundColor(.primary)
                                .fontWeight(.medium)
                        }

                        Spacer()

                        Button(action: {
                            UIPasteboard.general.string = expectedCodeRaw
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                isCodeCopied = true
                                verificationCode = expectedCodeRaw
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: isCodeCopied ? "checkmark" : "doc.on.doc.fill")
                                Text(isCodeCopied ? "Copied" : "Copy")
                            }
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(isCodeCopied ? .white : .blue)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(isCodeCopied ? Color.green : Color.blue.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .disabled(isCodeCopied)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                    .padding(.horizontal, 10)
                    .padding(.top, 10)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.top, 40)

            VStack(spacing: 16) {
                if !isCodeSent {
                    HStack {
                        Image(systemName: "phone.fill")
                            .foregroundColor(.blue)
                        TextField("e.g. +353 87 123 4567", text: $phoneNumber)
                            .keyboardType(.phonePad)
                            .textContentType(.telephoneNumber)
                            .focused($isPhoneFocused)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                } else {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.shield.fill")
                                .foregroundColor(.blue)
                            TextField("6-Digit Code", text: $verificationCode)
                                .keyboardType(.numberPad)
                                .textContentType(.oneTimeCode)
                                .focused($isCodeFocused)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                        Button(action: {
                            withAnimation {
                                isCodeSent = false
                                verificationCode = ""
                                errorMessage = ""
                                isCodeCopied = false
                                isPhoneFocused = true
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.backward")
                                Text("Edit Phone Number")
                            }
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .fontWeight(.medium)
                        }
                        .padding(.top, 4)
                    }
                }

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 24)

            HStack {
                Spacer()
                Button(action: {
                    if !isCodeSent {
                        handleSendPipeline()
                    } else {
                        handleValidationPipeline()
                    }
                }) {
                    Text(isCodeSent ? "Verify & Enter" : "Send Code")
                        .padding(.vertical, 14)
                        .padding(.horizontal, 64)
                        .font(.headline)
                        .foregroundColor(.white)
                        .background(
                            Capsule()
                                .fill(isInputEmpty ? Color.gray.opacity(0.5) : Color.blue)
                        )
                }
                .buttonStyle(.plain)
                .disabled(isInputEmpty)
                Spacer()
            }
            .padding(.top, 10)

            Spacer()
        }
        .padding()
        .onAppear {
            isPhoneFocused = true
        }
        .fontDesign(.rounded)
    }

    private func handleSendPipeline() {
        guard phoneNumber.count >= 7 else {
            errorMessage = "Please enter a valid phone number."
            return
        }

        errorMessage = ""
        isCodeCopied = false

        let generatedResult = PhoneAuthService.sendCode(to: phoneNumber)

        self.expectedCodeRaw = generatedResult.raw

        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            self.isCodeSent = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.isCodeFocused = true
        }
    }

    private func handleValidationPipeline() {
        errorMessage = ""

        let isIdentified = PhoneAuthService.validate(verificationCode, against: expectedCodeRaw)

        if isIdentified {
           onAuthSuccess()
        } else {
            errorMessage = "Invalid verification code. Please try again."
        }
    }
}

#Preview {
    PhoneAuthView(onAuthSuccess: {})
}
