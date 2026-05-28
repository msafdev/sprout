//
//  LessonDetailView.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//
import SwiftUI
import _PhotosUI_SwiftUI
import SwiftData

struct LessonDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var milestone: Milestone
    let accent: Color

    @State private var showingDeleteAlert = false
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        ZStack {
            SkyLearningBackground()

            VStack(spacing: 0) {
                DetailTopBar(
                    title: "Lesson",
                    onBack: { dismiss() },
                    onEdit: {
                        if milestone.isReadyToComplete {
                            milestone.markCompleted()
                        }
                        dismiss()
                    }
                )
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 14)
                .background(
                    SkyLearningHeaderBackground()
                        .opacity(0.97)
                        .ignoresSafeArea(edges: .top)
                )
                .shadow(color: .black.opacity(0.035), radius: 10, y: 5)
                .zIndex(10)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Lesson Title")
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(.black.opacity(0.35))

                            TextField("Lesson title", text: $milestone.title, axis: .vertical)
                                .font(.system(size: 28, weight: .black))
                                .foregroundStyle(.black)
                                .lineLimit(1...3)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Photo")
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(.black.opacity(0.35))

                            LessonPhotoPicker(
                                photoData: milestone.photoData,
                                accent: accent,
                                selectedPhotoItem: $selectedPhotoItem,
                                removeAction: {
                                    milestone.photoData = nil
                                    milestone.markIncomplete()
                                }
                            )
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Explanation")
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(.black.opacity(0.35))

                            ExpandingExplanationField(text: $milestone.explanation)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("How did you feel after finishing this lesson?")
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(.black.opacity(0.35))

                            FeelingPicker(selectedScore: $milestone.feelingScore, accent: accent)
                        }

                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Text("Delete")
                                .font(.system(size: 15, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.black.opacity(0.06))
                                .clipShape(Capsule())
                        }
                        .padding(.top, 8)
                    }
                    .padding(20)
                    .background(.white.opacity(0.86))
                    .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                    .shadow(color: .black.opacity(0.08), radius: 24, y: 14)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .safeAreaPadding(.bottom, 28)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }

            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        milestone.photoData = data
                        milestone.markIncomplete()
                    }
                }
            }
        }
        .onChange(of: milestone.explanation) { _, _ in
            if !milestone.isReadyToComplete {
                milestone.markIncomplete()
            }
        }
        .onChange(of: milestone.feelingScore) { _, _ in
            if !milestone.isReadyToComplete {
                milestone.markIncomplete()
            }
        }
        .alert("Delete lesson?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                modelContext.delete(milestone)
                dismiss()
            }
        }
    }
}
