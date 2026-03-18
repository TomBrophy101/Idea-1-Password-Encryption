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
    @State private var tempEmail = "No Email Generated"

    var body: some View {
        NavigationSplitView {
            List {
                Section("New Entry") {
                    TextField("Title", text: $inputTitle)
                    SecureField("Password", text: $inputPassword)
                    Button("Save to Vault", action: addItem)
                        .disabled(inputTitle.isEmpty || inputPassword.isEmpty)
                }
                Section("Saved Items") {
                    ForEach(items) { item in
                        NavigationLink {
                            Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                        } label: {
                            Text(item.title.isEmpty ? "Untitled" : item.title)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
            }
            .navigationTitle("My Passwords")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        } detail: {
            ZStack {
                Color.blue.opacity(0.1).ignoresSafeArea()
                Text("Select an item")
            }
        }
        .navigationSplitViewStyle(.balanced)
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(title: "New Password Entry", serviceType: "Login", secureData: "EncryptedData", timestamp: Date())
            modelContext.insert(newItem)
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
