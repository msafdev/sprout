//
//  EntryDetailView.swift
//  Sprout
//
//  Created by Salman Alfarisi on 25/05/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct EntryDetailView: View {
    @Bindable var entry: Milestone
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImage: PhotosPickerItem? = nil
    
    private var entryImage: Image? {
        guard let data = entry.imageData,
              let uiImage = UIImage(data: data) else {
            return nil
        }
        return Image(uiImage: uiImage)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header with back button
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        try? modelContext.save()
                        dismiss()
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark")
                            Text("Save")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                VStack(alignment: .leading, spacing: 20) {
                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Lesson Title")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                        
                        TextField("Entry Title", text: $entry.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .textFieldStyle(PlainTextFieldStyle())
                            .onSubmit { try? modelContext.save() }
                    }
                    
                    // Image/Photo Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Photo")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                        
                        PhotosPicker(selection: $selectedImage, matching: .images, photoLibrary: .shared()) {
                            ZStack {
                                if let entryImage {
                                    entryImage
                                        .resizable()
                                        .aspectRatio(4/3, contentMode: .fill)
                                        .frame(maxWidth: .infinity)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                } else {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.gray.opacity(0.15))
                                        .aspectRatio(4/3, contentMode: .fit)
                                        .overlay(
                                            VStack(spacing: 12) {
                                                Image(systemName: "plus.circle")
                                                    .font(.system(size: 40))
                                                    .foregroundColor(.gray)
                                                Text("Add Photo")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                        )
                                }
                            }
                        }
                        .onChange(of: selectedImage) { newItem in
                            guard let item = newItem else { return }
                            Task {
                                if let data = try? await item.loadTransferable(type: Data.self) {
                                    entry.imageData = data
                                    try? modelContext.save()
                                }
                            }
                        }
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Explanation")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.gray)
                        
                        TextEditor(text: $entry.content)
                            .font(.body)
                            .frame(minHeight: 100)
                            .padding(12)
                            .background(Color.gray.opacity(0.08))
                            .cornerRadius(12)
                            .onSubmit { try? modelContext.save() }
                    }
                    
                    // Emotion Level
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How did you feel after finishing this lesson?")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        HStack(spacing: 16) {
                            ForEach(1...5, id: \.self) { level in
                                VStack(spacing: 4) {
                                    Button(action: {
                                        entry.emotionLevel = (entry.emotionLevel == level) ? 0 : level
                                        try? modelContext.save()
                                    }) {
                                        emotionEmoji(for: level)
                                            .font(.system(size: 32))
                                            .scaleEffect(entry.emotionLevel == level ? 1.2 : 1.0)
                                            .opacity(entry.emotionLevel == level ? 1.0 : 0.5)
                                    }
                                }
                            }
                            Spacer()
                        }
                    }
                    
                    // Delete Button
                    VStack(spacing: 12) {
                        Button(action: { /* Handle delete */ }) {
                            Text("Delete")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(14)
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .onChange(of: entry.title) { _, _ in
            try? modelContext.save()
        }
        .onChange(of: entry.content) { _, _ in
            try? modelContext.save()
        }
    }
    
    private func emotionEmoji(for level: Int) -> Text {
        let emojis = ["😢", "😕", "😐", "🙂", "😄"]
        return Text(emojis[level - 1])
    }
}
