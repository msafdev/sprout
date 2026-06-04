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
                VStack(alignment: .leading, spacing: 16) {
                    // Main content card
                    VStack(alignment: .leading, spacing: 20) {
                        // Title
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Lesson Title")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)

                            TextField("Entry Title", text: $entry.title, axis: .vertical)
                                .font(.title2)
                                .fontWeight(.bold)
                                .textFieldStyle(PlainTextFieldStyle())
                                .lineLimit(1...)
                        }

                        Divider()

                        // Image/Photo Section
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Photo")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)

                            ZStack(alignment: .topTrailing) {
                                PhotosPicker(selection: $selectedImage, matching: .images, photoLibrary: .shared()) {
                                    if let entryImage {
                                        entryImage
                                            .resizable()
                                            .aspectRatio(4/3, contentMode: .fill)
                                            .frame(maxWidth: .infinity)
                                            .clipShape(RoundedRectangle(cornerRadius: 14))
                                    } else {
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.appBackground)
                                            .aspectRatio(4/3, contentMode: .fit)
                                            .overlay(
                                                VStack(spacing: 10) {
                                                    Image(systemName: "plus.circle")
                                                        .font(.system(size: 36))
                                                        .foregroundColor(.gray.opacity(0.6))
                                                    Text("Add Photo")
                                                        .font(.subheadline)
                                                        .foregroundColor(.gray.opacity(0.6))
                                                }
                                            )
                                    }
                                }
                                .onChange(of: selectedImage) { _, newItem in
                                    guard let item = newItem else { return }
                                    Task {
                                        if let data = try? await item.loadTransferable(type: Data.self) {
                                            entry.imageData = data
                                            try? modelContext.save()
                                        }
                                    }
                                }

                                if entry.imageData != nil {
                                    Button(action: {
                                        entry.imageData = nil
                                        selectedImage = nil
                                        try? modelContext.save()
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 26))
                                            .foregroundStyle(.white, Color.black.opacity(0.55))
                                    }
                                    .padding(8)
                                }
                            }
                        }
                        
                        Divider()

                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Explanation")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                            
                            TextField("Write your explanation here...", text: $entry.content, axis: .vertical)
                                .font(.body)
                                .lineLimit(4...)
                                .textFieldStyle(PlainTextFieldStyle())
                        }
                            
                        .onChange(of: selectedImage) { _, newItem in
                            guard let item = newItem else { return }
                            Task {
                                if let data = try? await item.loadTransferable(type: Data.self) {
                                    entry.imageData = data
                                    try? modelContext.save()
                                }
                            }
                        }

                        Divider()

                        // Emotion Level
                        VStack(alignment: .leading, spacing: 12) {
                            Text("How did you feel?")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)

                            HStack(spacing: 16) {
                                ForEach(1...5, id: \.self) { level in
                                    Button(action: {
                                        entry.emotionLevel = (entry.emotionLevel == level) ? 0 : level
                                        try? modelContext.save()
                                    }) {
                                        emotionImage(for: level, isSelected: entry.emotionLevel == level)
                                    }
                                }
                                Spacer()
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.appCard)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)

                    // Delete Button
                    Button(action: {
                        if let roadmap = entry.roadmap {
                            roadmap.milestones.removeAll { $0.id == entry.id }
                        }
                        modelContext.delete(entry)
                        try? modelContext.save()
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Delete Milestone")
                        }
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.red.opacity(0.08))
                        .clipShape(Capsule())
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 28)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(Color.primary.opacity(0.08))
                        .clipShape(Circle())
                }

                Spacer()

                Button(action: {
                    try? modelContext.save()
                    dismiss()
                }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.appAccent)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 8)
            .background(Color.appBackground)
        }
        .background(Color.appBackground)
        .navigationBarHidden(true)
        .onChange(of: entry.title) { _, _ in
            try? modelContext.save()
        }
        .onChange(of: entry.content) { _, _ in
            try? modelContext.save()
        }
    }
    
    private func emotionImage(for level: Int, isSelected: Bool = false) -> some View {
        let moodAssets = ["s_angry", "s_confused", "s_sad", "s_flat", "s_happy"]
        let index = max(0, min(level - 1, moodAssets.count - 1))
        return Image(moodAssets[index])
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .scaleEffect(isSelected ? 1.2 : 1.0)
            .opacity(isSelected ? 1.0 : 0.45)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
    }
}
