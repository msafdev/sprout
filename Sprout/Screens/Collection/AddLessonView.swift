import SwiftUI
import SwiftData

struct AddLessonView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var collection: LearningCollection

    @State private var lessonTitles: [String] = []
    @State private var currentTitle = ""
    @FocusState private var isTitleFieldFocused: Bool

    private let listAreaHeight: CGFloat = 172

    private var trimmedCurrentTitle: String {
        currentTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var titlesToSave: [String] {
        var titles = lessonTitles
        if !trimmedCurrentTitle.isEmpty {
            titles.append(trimmedCurrentTitle)
        }
        return titles
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "#F4F4F8").ignoresSafeArea()

                VStack(alignment: .leading, spacing: 20) {
                    toolbarRow
                    headerText

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Lesson Titles")
                            .font(.system(size: 17, weight: .black))
                            .foregroundStyle(.black.opacity(0.42))

                        VStack(spacing: 14) {
                            lessonListArea.frame(height: listAreaHeight)
                            lessonInputBar
                        }
                    }

                    if !titlesToSave.isEmpty {
                        Text("\(titlesToSave.count) lesson\(titlesToSave.count == 1 ? "" : "s") will be added")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color(hex: "#A5A827"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color(hex: "#A5A827").opacity(0.12))
                            .clipShape(Capsule())
                    }

                    Spacer()
                }
                .padding(.horizontal, 26)
                .padding(.top, 24)
            }
            .onAppear { isTitleFieldFocused = true }
        }
    }

    private var toolbarRow: some View {
        HStack {
            pillButton("Cancel", color: .black) { dismiss() }

            Spacer()

            pillButton(
                "Save",
                color: titlesToSave.isEmpty ? .black.opacity(0.25) : Color(hex: "#A5A827"),
                weight: .semibold,
                action: saveLessons
            )
            .disabled(titlesToSave.isEmpty)
        }
    }

    private func pillButton(
        _ label: String,
        color: Color,
        weight: Font.Weight = .medium,
        action: @escaping () -> Void
    ) -> some View {
        Button(label, action: action)
            .font(.system(size: 17, weight: weight))
            .foregroundStyle(color)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(.white.opacity(0.9))
            .clipShape(Capsule())
    }

    private var headerText: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("New Lessons")
                .font(.system(size: 38, weight: .black))
                .foregroundStyle(.black)

            Text("Type a lesson title, then press return to add it to the list. You can remove any title before saving.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.black.opacity(0.45))
                .lineSpacing(3)
        }
    }

    private var lessonListArea: some View {
        ZStack {
            if lessonTitles.isEmpty {
                emptyLessonPlaceholder
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(Array(lessonTitles.enumerated()), id: \.offset) { index, title in
                            PendingLessonRow(
                                number: index + 1,
                                title: title,
                                removeAction: { removeLessonTitle(at: index) }
                            )
                        }
                    }
                    .padding(.vertical, 2)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.snappy(duration: 0.22), value: lessonTitles.count)
    }

    private var emptyLessonPlaceholder: some View {
        VStack(spacing: 10) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(Color(hex: "#A5A827").opacity(0.55))

            Text("No lesson titles yet")
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(.black.opacity(0.38))

            Text("Press return after typing a title to add it here.")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.black.opacity(0.28))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white.opacity(0.65))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }

    private var lessonInputBar: some View {
        HStack(spacing: 12) {
            TextField("Input lesson title...", text: $currentTitle)
                .font(.system(size: 17, weight: .bold))
                .focused($isTitleFieldFocused)
                .submitLabel(.done)
                .onSubmit(addCurrentTitle)

            Button(action: addCurrentTitle) {
                Image(systemName: "plus")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(trimmedCurrentTitle.isEmpty ? Color.black.opacity(0.16) : Color(hex: "#A5A827"))
                    .clipShape(Circle())
            }
            .disabled(trimmedCurrentTitle.isEmpty)
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func addCurrentTitle() {
        guard !trimmedCurrentTitle.isEmpty else { return }

        withAnimation(.snappy(duration: 0.22)) {
            lessonTitles.append(trimmedCurrentTitle)
            currentTitle = ""
        }

        isTitleFieldFocused = true
    }

    private func removeLessonTitle(at index: Int) {
        guard lessonTitles.indices.contains(index) else { return }

        withAnimation(.snappy(duration: 0.22)) {
            lessonTitles.remove(at: index)
        }
    }

    private func saveLessons() {
        let finalTitles = titlesToSave
        guard !finalTitles.isEmpty else { return }

        let startIndex = collection.lessons.count

        for (offset, title) in finalTitles.enumerated() {
            let lesson = Lesson(
                title: title,
                orderIndex: startIndex + offset,
                collection: collection
            )

            collection.lessons.append(lesson)
            modelContext.insert(lesson)
        }

        dismiss()
    }
}

struct PendingLessonRow: View {
    let number: Int
    let title: String
    let removeAction: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(String(format: "%02d", number))
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(Color(hex: "#A5A827"))
                .frame(width: 38, height: 38)
                .background(Color(hex: "#A5A827").opacity(0.11))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text(title)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(.black)
                .lineLimit(2)

            Spacer(minLength: 8)

            Button(action: removeAction) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(.black.opacity(0.38))
                    .frame(width: 32, height: 32)
                    .background(Color.black.opacity(0.06))
                    .clipShape(Circle())
            }
        }
        .padding(12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
    }
}
