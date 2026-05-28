//
//  AddCollectionView.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//
import SwiftUI
import SwiftData
struct AddCollectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var goalDescription = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Collection") {
                    TextField("Title", text: $title)
                    TextField("Goal Description", text: $goalDescription, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("New Collection")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let roadmap = Roadmap(
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                            goalDescription: goalDescription.trimmingCharacters(in: .whitespacesAndNewlines),
                            colorHex: "#A5A827"
                        )
                        modelContext.insert(roadmap)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
