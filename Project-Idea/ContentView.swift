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

    var body: some View {
        NavigationSplitView {
            List {
                //This is the bread and butter of the App.
                Section("Add New Account") {
                    TextField("Web Page or App Name", text: $inputTitle)
                        .textContentType(.organizationName)
                        .autocorrectionDisabled()
                        .textContentType(.URL)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)

                    TextField("Enter Email", text: $tempEmail)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)

                    SecureField("Enter Password", text: $inputPassword)
                        .textContentType(.newPassword)

                    HStack {
                        TextField("Enter 2 Factor Code", text: $current2FACode)
                            .keyboardType(.numberPad)
                            .textContentType(.oneTimeCode)
                            .submitLabel(.done)

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

            .safeAreaInset(edge: .bottom) {
                if !expectedCode.isEmpty && current2FACode.isEmpty {
                    Button {
                        current2FACode = expectedCode
                    } label: {
                        HStack {
                            Image(systemName: "message.fill")
                            Text("From Messages:")
                            Text(expectedCode).bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.1), radius: 5)
                    }
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func sendFakeSMS() {

        let newCode = String(Int.random(in: 100000...999999))
        expectedCode = newCode


        UIPasteboard.general.string = newCode

        UINotificationFeedbackGenerator().notificationOccurred(.success)

        print("Code is now on clipboard: \(newCode)")
    }

    private func addItem() {

        guard current2FACode == expectedCode else {
            print("Incorrect code")
            return
        }
        withAnimation {
            let newItem = Item(
                title: inputTitle,
                serviceType: "Login",
                secureData: "Email: \(tempEmail)\nPassword: \(inputPassword)\n2 Factor Code: \(current2FACode)",
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
