import SwiftUI
import SwiftData

struct EditCollectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var collection: LearningCollection

    var body: some View {
        NavigationStack {
            Form {
                Section("Collection") {
                    TextField("Title", text: $collection.title)
                    TextField("Summary", text: $collection.summary, axis: .vertical)
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
