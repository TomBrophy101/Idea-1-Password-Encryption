//
//  ContentView.swift
//  SalusPass
//
//  Created by Tom Brophy on 10/03/2026.
//  This is the main menu of the program.

import SwiftUI
import SwiftData

struct ContentView: View {
    var onLock: () -> Void
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]

    @State private var columnVisibility = NavigationSplitViewVisibility.all

    @State private var inputTitle = ""
    @State private var tempEmail = ""
    @State private var inputPassword = ""
    @State private var current2FACode = ""
    @State private var expectedCode = ""

    @State private var isEmailVisible = false
    @State private var isPasswordVisible = false

    @FocusState private var isTitleFocused: Bool
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    @FocusState private var is2FAFocused: Bool


    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            List {
                //This is the bread and butter of the App.
                Section("Add New Account") {

                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Web Page or App Name", text: $inputTitle)
                            .textContentType(.URL)
                            .keyboardType(.URL)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .focused($isTitleFocused)
                            .onChange(of: inputTitle) { _, newValue in
                                cleanURLToTitle(newValue)
                            }

                        if isTitleFocused {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(["Google", "Instagram", "Netflix", "Amazon", "X", "Facebook", "WhatsApp", "Revolut", "Tinder"], id: \.self) { app in
                                        Button(app) {
                                            inputTitle = app
                                            isEmailFocused = true
                                        }
                                        .buttonStyle(.bordered)
                                        .tint(.blue)
                                        .controlSize(.small)
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }

                    HStack {
                        //This is to generate a complicated email for the user.
                        TextField("Enter Email", text: $tempEmail)
                            .textContentType(.username)
                            .keyboardType(.emailAddress)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .focused($isEmailFocused)

                        Menu {
                            Button {
                                tempEmail = EmailService.createRandomEmail()
                            } label: {
                                Label("Generate Random Email", systemImage: "dice")
                            }
                            Divider()
                            let savedEmails = getUniqueSavedEmails()
                            if savedEmails.isEmpty {
                                Text("No saved emails")
                            } else {
                                Section("Saved Emails") {
                                    ForEach(getUniqueSavedEmails(), id: \.self) { email in
                                        Button(email) { tempEmail = email }
                                    }
                                }
                            }
                        } label: {
                            Image(systemName: "at.badge.plus")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(.blue)
                                .padding(8)
                                .background(Color(.systemBackground))
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("at.badge.plus_menu")
                    }

                    //This is to create a complicated password for the user.
                    HStack(spacing: 10) {
                        Group {
                            if isPasswordVisible {
                                TextField("Enter Password", text: $inputPassword)
                                    .focused($isPasswordFocused)

                            } else {
                                SecureField("Enter Password", text: $inputPassword)
                                    .focused($isPasswordFocused)
                            }
                        }
                        .textContentType(.newPassword)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()

                        Button {
                            isPasswordVisible.toggle()
                            isPasswordFocused = true
                        } label: {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.blue)
                                .frame(width: 30, height: 30)
                        }
                        .buttonStyle(.plain)

                        Button {
                            inputPassword = PasswordGeneratorService.generate(length: 16, includeSymbols: true, includeNumbers: true)
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                        } label: {
                            Image(systemName: "dice")
                                .foregroundColor(.blue)
                                .padding(8)
                                .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }


                    //This is to send the 2 factor authentication code to the supposed phone number of the user.
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            TextField("Enter 2 Factor Code", text: $current2FACode)
                                .keyboardType(.numberPad)
                                .textContentType(.oneTimeCode)
                                .focused($is2FAFocused)

                            Button("Send Code") {
                                sendFakeSMS()
                            }
                            .buttonStyle(.bordered)
                            .tint(.blue)
                            .controlSize(.small)
                        }

                        if is2FAFocused && !expectedCode.isEmpty && current2FACode.isEmpty {
                            Button {
                                withAnimation { current2FACode = expectedCode }
                            } label : {
                                HStack {
                                    Image(systemName: "message.fill")
                                    Text("From Messages: \(expectedCode)").bold()
                                    Spacer()
                                }
                                .font(.footnote)
                                .padding(8)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                //This is to save all the information for the user.
                Section {
                    HStack {
                        Spacer()
                        Button(action: addItem) {
                            Text("Save to Vault")
                                .padding(.vertical, 14)
                                .padding(.horizontal, 64)
                                .font(.headline)
                                .foregroundColor(.white)
                                .background(
                                    Capsule()
                                        .fill(isFormInvalid ? Color.gray.opacity(0.5) : Color.blue)
                                )
                        }
                        .buttonStyle(.plain)
                        .disabled(isFormInvalid)
                        Spacer()
                    }
                    .padding(.top, 10)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())

                Section("Saved Accounts") {
                    ForEach(items) { item in
                        NavigationLink {
                            DetailView(item: item)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(item.title)
                                    .font(.headline)
                                Text(item.timestamp, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .accessibilityIdentifier("MainList")
            .navigationTitle("SalusPass")
            .background(Color(UIColor.systemGroupedBackground))
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                }
            }
        } detail: {
            Text("Select an item")
        }
        .navigationSplitViewStyle(.balanced)
    }

    private var isFormInvalid: Bool {
        inputTitle.isEmpty || inputPassword.isEmpty || tempEmail.isEmpty || current2FACode.isEmpty
    }

    private func cleanURLToTitle(_ urlString: String) {
        let lowcased = urlString.lowercased()

        if lowcased.contains(".") && !lowcased.hasSuffix(".") {
            if lowcased.hasPrefix("http") || lowcased.hasPrefix("https") || lowcased.hasPrefix("www.") {
                var cleaned = lowcased
                    .replacingOccurrences(of: "https://", with: "")
                    .replacingOccurrences(of: "http://", with: "")
                    .replacingOccurrences(of: "www.", with: "")

                if let firstDot = cleaned.firstIndex(of: "."), firstDot != cleaned.startIndex {
                    cleaned = String(cleaned[..<firstDot])
                }
                inputTitle = cleaned.capitalized
            }
        }
    }

    //This is what I used to use to make the email for the user.
    //    private func generateRandomEmail() {
    //        let prefix = ["user", "mail", "vault", "proxy", "hidden", "cheese", "mac", "x22", "x23", "x24", "x25", "x26"]
    //        let domains = ["icloud.com", "fastmail.com", "gmail.com", "outlook.com", "student.ncirl.ie"]
    //
    //        tempEmail = "\(prefix.randomElement()!)\(Int.random(in: 100000...999999))@\(domains.randomElement()!)"
    //    }

    //This is the elements to make the email for the user.
    private func getUniqueSavedEmails() -> [String] {
        var emails = Set<String>()
        let key = KeychainManager.getOrCreateMasterKey()

        for item in items {
            if let decrypted = EncryptionManager.decrypt(item.secureData, key: key) {
                let lines = decrypted.components(separatedBy: "\n")
                if let emailLine = lines.first(where: { $0.hasPrefix("Email: ") }) {
                    emails.insert(emailLine.replacingOccurrences(of: "Email: ", with: ""))
                }
            }
        }
        return Array(emails).sorted()
    }

    private func sendFakeSMS() {
        let codePair = TwoFactorService.generateCode()

        withAnimation {
            expectedCode = codePair.raw
        }

        //UIPasteboard.general.string = codePair.formatted

        UINotificationFeedbackGenerator().notificationOccurred(.success)

        print("Code is now on clipboard: \(codePair)")
    }

    private func addItem() {

        guard TwoFactorService.validate(current2FACode, against: expectedCode) else {
            return
        }
        let key = KeychainManager.getOrCreateMasterKey()
        let rawString = "Email: \(tempEmail)\nPassword: \(inputPassword)\n"

        if let encryptedString = EncryptionManager.encrypt(rawString, key: key) {
            let newItem = Item(
                title: inputTitle,
                serviceType: "Login",
                secureData: encryptedString,
                timestamp: Date()
            )
            modelContext.insert(newItem)

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            resetFields()
        }
    }

    private func resetFields() {
        inputTitle = ""; tempEmail = ""; inputPassword = ""; current2FACode = ""; expectedCode = ""
        isEmailVisible = false
        isPasswordVisible = false
        is2FAFocused = false
    }

    private func deleteItems(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(items[index])
        }
    }
}

#Preview {
    ContentView(onLock: {})
        .modelContainer(for: Item.self, inMemory: true)
}
