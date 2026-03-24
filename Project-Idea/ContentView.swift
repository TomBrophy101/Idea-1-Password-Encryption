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
    @State private var current2FACode = "------"
    @State private var tempEmail = ""

    var body: some View {
        NavigationSplitView {
            List {
                Section("Add New Account") {
                    TextField("Web Page or App Name", text: $inputTitle)
                        .textContentType(.organizationName)
                        .autocorrectionDisabled()

                    TextField("Enter Email", text: $tempEmail)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)

                    SecureField("Enter Password", text: $inputPassword)
                        .textContentType(.newPassword)
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
                .disabled(inputTitle.isEmpty || inputPassword.isEmpty || tempEmail.isEmpty)

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
            .navigationTitle("Project Idea")
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(
                title: inputTitle,
                serviceType: "Login",
                secureData: "Email: \(tempEmail), Password: \(inputPassword)",
                timestamp: Date()
            )
            modelContext.insert(newItem)

            inputTitle = ""
            tempEmail = ""
            inputPassword = ""
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
