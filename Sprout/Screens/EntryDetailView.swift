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
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showPhotosPicker = false // 👇 Tracks library picker presentation
    
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var showDeleteConfirmation = false
    @State private var showCamera = false // 👇 Tracks custom camera presentation
    
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
                            Text("Milestone")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)

                            TextField("Milestone Title", text: $entry.title, axis: .vertical)
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
                                // 👇 Replaced direct PhotosPicker with a choice Menu for clean UX
                                Menu {
                                    Button(action: { showCamera = true }) {
                                        Label("Take Photo", systemImage: "camera")
                                    }
                                    
                                    // 👇 Fixed: Replaced raw PhotosPicker struct with a standard menu action Button
                                        Button(action: { showPhotosPicker = true }) {
                                            Label("Choose from Library", systemImage: "photo.on.rectangle")
                                        }
                                    } label: {
                                    if let entryImage {
                                        entryImage
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: .infinity)
                                            .clipShape(RoundedRectangle(cornerRadius: 14))
                                    } else {
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(Color.appBackground)
                                            .frame(height: 200)
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
                                .buttonStyle(PlainButtonStyle()) // Keeps original frame styling intact

                                // Delete Button overlayed on top right
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

                        Divider()

                        // Emotion Level
                        VStack(alignment: .leading, spacing: 12) {
                            Text("How did you feel?")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)

                            HStack(spacing: 0) {
                                ForEach(1...5, id: \.self) { level in
                                    let isSelected = entry.emotionLevel == level
                                    Button(action: {
                                        entry.emotionLevel = (entry.emotionLevel == level) ? 0 : level
                                        try? modelContext.save()
                                    }) {
                                        emotionImage(for: level, isSelected: isSelected)
                                            .scaleEffect(isSelected ? 1.2 : 1.0)
                                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: entry.emotionLevel)
                                            .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(Color.appCard)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)

                    // Delete Button
                    Button(action: {
                        showDeleteConfirmation = true
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
                .padding(.bottom, 128)
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
                        .foregroundColor(colorScheme == .dark ? .black : .white)
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
        // 👇 Listens to Photo Library Selection changes
        .onChange(of: selectedImage) { _, newItem in
            guard let item = newItem else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        entry.imageData = data
                        try? modelContext.save()
                    }
                }
            }
        }
        // 👇 Saves inline Textfield Title edits dynamically
        .onChange(of: entry.title) { _, _ in
            try? modelContext.save()
        }
        // 👇 Saves inline Textfield Explanation edits dynamically
        .onChange(of: entry.content) { _, _ in
            try? modelContext.save()
        }
        .alert("Delete Milestone?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                if let roadmap = entry.roadmap {
                    roadmap.milestones.removeAll { $0.id == entry.id }
                }
                modelContext.delete(entry)
                try? modelContext.save()
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this milestone? This action cannot be undone.")
        }
        // 👇 Presents your custom camera view layout
        .fullScreenCover(isPresented: $showCamera) {
            CameraForRoadmap(
                selectedTab: .constant(0),
                roadmapTitle: entry.roadmap?.title ?? "",
                milestoneTitle: entry.title
            ) { capturedUIImage in
                // Direct callback hook updates model context instantly
                if let data = capturedUIImage.jpegData(compressionQuality: 0.8) {
                    entry.imageData = data
                    try? modelContext.save()
                }
                showCamera = false
            }
        }
        .photosPicker(
                    isPresented: $showPhotosPicker,
                    selection: $selectedImage,
                    matching: .images,
                    photoLibrary: .shared()
                )
    }
    
    private func emotionImage(for level: Int, isSelected: Bool) -> some View {
        let moodAssets = ["s_angry", "s_confused", "s_sad", "s_flat", "s_happy"]
        let index = max(0, min(level - 1, moodAssets.count - 1))
        return Image(moodAssets[index])
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40)
            .opacity(isSelected ? 1.0 : 0.45)
    }
}
