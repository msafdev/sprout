import SwiftUI
import SwiftData
import PhotosUI

struct LessonDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var lesson: Lesson
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
                    onEdit: { dismiss() }
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
                        section(title: "Lesson Title") {
                            TextField("Lesson title", text: $lesson.title, axis: .vertical)
                                .font(.system(size: 28, weight: .black))
                                .foregroundStyle(.black)
                                .lineLimit(1...3)
                        }

                        section(title: "Photo") {
                            LessonPhotoPicker(
                                photoData: lesson.photoData,
                                accent: accent,
                                selectedPhotoItem: $selectedPhotoItem,
                                removeAction: { lesson.photoData = nil }
                            )
                        }

                        section(title: "Explanation") {
                            ExpandingExplanationField(text: $lesson.explanation)
                        }

                        section(title: "How did you feel after finishing this lesson?") {
                            FeelingPicker(selectedScore: $lesson.feelingScore, accent: accent)
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
                    await MainActor.run { lesson.photoData = data }
                }
            }
        }
        .alert("Delete lesson?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                modelContext.delete(lesson)
                dismiss()
            }
        }
    }

    @ViewBuilder
    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(.black.opacity(0.35))
            content()
        }
    }
}

struct DetailTopBar: View {
    let title: String
    let onBack: () -> Void
    let onEdit: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.9))
                    .clipShape(Circle())
            }

            Spacer()

            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.black.opacity(0.7))

            Spacer()

            Button(action: onEdit) {
                Image(systemName: "checkmark")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color(hex: "#A5A827"))
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.9))
                    .clipShape(Circle())
            }
        }
    }
}
