//
//  ContentView.swift
//  Project-Idea
//
//  Created by Tom Brophy on 10/03/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.timestamp, order: .reverse) private var items: [Item]

    @State private var inputTitle = ""
    @State private var inputPassword = ""
    @State private var current2FACode = ""
    @State private var tempEmail = ""
    @State private var expectedCode = ""

    @FocusState private var isEmailFocused: Bool
    @FocusState private var is2FAFocused: Bool
    @FocusState private var isTitleFocused: Bool

    var body: some View {
        NavigationSplitView {
            List {
                //This is the bread and butter of the App.
                Section("Add New Account") {
                    TextField("Web Page or App Name", text: $inputTitle)
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .focused($isTitleFocused)
                        .onChange(of: inputTitle) {
                            if inputTitle.contains(".") && !inputTitle.hasSuffix(".") {
                                if inputTitle.lowercased().hasPrefix("http://") || inputTitle.lowercased().hasPrefix("https://") || inputTitle.lowercased().hasPrefix("www.") {
                                    cleanURLToTitle(inputTitle)
                                }
                            }
                        }
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                if isTitleFocused {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ForEach(["Google", "Instagram", "Netflix", "Amazon", "X", "Facebook", "WhatsApp", "Revolut"], id: \.self) { app in
                                                Button(app) {
                                                    inputTitle = app
                                                    isEmailFocused = true
                                                }
                                                .buttonStyle(.bordered)
                                                .tint(.blue)
                                                .controlSize(.small)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }

                    TextField("Enter Email", text: $tempEmail)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .focused($isEmailFocused)
                        .toolbar {
                            ToolbarItemGroup(placement: .keyboard) {
                                if isEmailFocused {
                                    Menu {
                                        Button(action: generateRandomEmail) {
                                            Label("Generate Random Email", systemImage: "dice")
                                                .foregroundStyle(.blue)
                                        }

                                        Divider()

                                        Section("Saved Emails") {
                                            ForEach(getUniqueSavedEmails(), id: \.self) { email in
                                                Button(email) { tempEmail = email }
                                            }
                                        }

                                    } label: {
                                        Label("Email Options", systemImage: "at.badge.plus")
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.blue)
                                    }
                                    Spacer()
                                }
                            }
                        }

                    SecureField("Enter Password", text: $inputPassword)
                        .textContentType(.newPassword)

                    HStack {
                        TextField("Enter 2 Factor Code", text: $current2FACode)
                            .keyboardType(.numberPad)
                            .textContentType(.oneTimeCode)
                            .focused($is2FAFocused)
                            .submitLabel(.done)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    if is2FAFocused && !expectedCode.isEmpty && current2FACode.isEmpty {
                                        Button {
                                            withAnimation {
                                                current2FACode = expectedCode
                                            }
                                        } label : {
                                            HStack(spacing: 4) {
                                                Image(systemName: "message.fill")
                                                    .font(.caption)
                                                Text("From Messages: ")
                                                Text(expectedCode).bold()
                                            }
                                            .foregroundColor(.blue)
                                            .padding(.vertical, 6)
                                            .padding(.horizontal, 12)
                                            .background(Color.blue.opacity(0.2))
                                            .cornerRadius(8)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                            }


                        Button("Send Code to Phone Number") {
                            sendFakeSMS()
                        }
                        .buttonStyle(.bordered)
                        .tint(.blue)
                        .controlSize(.small)
                    }
                }

                Button(action: addItem) {
                    Text("Save to Vault")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .bold()
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .listRowBackground(Color.clear)
                .disabled(inputTitle.isEmpty || inputPassword.isEmpty || tempEmail.isEmpty || current2FACode.isEmpty)

                Section("Saved Accounts") {
                    ForEach(items) { item in
                        NavigationLink {
                            VStack(spacing: 20) {
                                Text(item.title).font(.largeTitle).bold()
                                Text(item.secureData).font(.body)
                                Spacer()
                            }
                            .padding()
                        } label: {
                            VStack(alignment: .leading) {
                                Text(item.title)
                                    .font(.headline)
                                Text(item.timestamp, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("Project-Idea")
        } detail: {
            Text("Select an item")
        }
    }

    private func cleanURLToTitle(_ urlString: String) {
        let lowcased = urlString.lowercased()

        var cleaned = lowcased
            .replacingOccurrences(of: "https://", with: "")
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "www.", with: "")

        if let firstDot = cleaned.firstIndex(of: ".") {
            cleaned = String(cleaned[..<firstDot])
        }

        let finalTitle = cleaned
        if inputTitle != finalTitle {
            inputTitle = finalTitle
        }

    }

    private func generateRandomEmail() {
        let prefix = ["user", "mail", "vault", "proxy", "hidden", "cheese", "mac", "x22", "x23", "x24", "x25", "x26"]
        let randomPrefix = prefix.randomElement() ?? "user"
        let randomNumber = Int.random(in: 100000...999999)
        let domains = ["icloud.com", "privaterelay.appleid.com", "fastmail.com", "gmail.com", "outlook.com", "student.ncirl.ie"]

        tempEmail = "\(randomPrefix)\(randomNumber)@\(domains.randomElement()!)"
    }

    private func getUniqueSavedEmails() -> [String] {
        var emails = Set<String>()
        for item in items {
            let lines = item.secureData.components(separatedBy: "\n")
            if let emailLine = lines.first(where: { $0.hasPrefix("Email: ") }) {
                let email = emailLine.replacingOccurrences(of: "Email: ", with: "")
                emails.insert(email)
            }
        }
        return Array(emails).sorted()
    }

    private func sendFakeSMS() {
        let newCode = String(Int.random(in: 100000...999999))

        withAnimation {
            expectedCode = newCode
        }

        UIPasteboard.general.string = newCode

        is2FAFocused = false

        UINotificationFeedbackGenerator().notificationOccurred(.success)

        print("Code is now on clipboard: \(newCode)")
    }

    private func addItem() {

        guard current2FACode == expectedCode else {
            return
        }
        withAnimation {
            let newItem = Item(
                title: inputTitle,
                serviceType: "Login",
                secureData: "Email: \(tempEmail)\nPassword: \(inputPassword)\n",
                timestamp: Date()
            )
            modelContext.insert(newItem)

            inputTitle = ""
            tempEmail = ""
            inputPassword = ""
            current2FACode = ""
            expectedCode = ""
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
