//
//  EditCollectionView.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//

import SwiftUI

struct EditCollectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var roadmap: Roadmap

    var body: some View {
        NavigationStack {
            Form {
                Section("Collection") {
                    TextField("Title", text: $roadmap.title)
                    TextField("Goal Description", text: $roadmap.goalDescription, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("Edit Collection")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
