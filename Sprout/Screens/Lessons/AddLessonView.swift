//
//  AddLessonView.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//
import SwiftUI
import SwiftData

struct AddLessonView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @Bindable var roadmap: Roadmap

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
                Color.fromHex("#F4F4F8")
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Button("Cancel") { dismiss() }
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.black)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(.white.opacity(0.9))
                            .clipShape(Capsule())

                        Spacer()

                        Button("Save") {
                            saveLessons()
                        }
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(titlesToSave.isEmpty ? .black.opacity(0.25) : Color.fromHex("#A5A827"))
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(.white.opacity(0.9))
                        .clipShape(Capsule())
                        .disabled(titlesToSave.isEmpty)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("New Lessons")
                            .font(.system(size: 38, weight: .black))
                            .foregroundStyle(.black)

                        Text("Type a lesson title, then press return to add it to the list. You can remove any title before saving.")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.black.opacity(0.45))
                            .lineSpacing(3)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Lesson Titles")
                            .font(.system(size: 17, weight: .black))
                            .foregroundStyle(.black.opacity(0.42))

                        VStack(spacing: 14) {
                            lessonListArea
                                .frame(height: listAreaHeight)

                            lessonInputBar
                        }
                    }

                    if !titlesToSave.isEmpty {
                        Text("\(titlesToSave.count) lesson\(titlesToSave.count == 1 ? "" : "s") will be added")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(Color.fromHex("#A5A827"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.fromHex("#A5A827").opacity(0.12))
                            .clipShape(Capsule())
                    }

                    Spacer()
                }
                .padding(.horizontal, 26)
                .padding(.top, 24)
            }
            .onAppear {
                isTitleFieldFocused = true
            }
        }
    }

    private var lessonListArea: some View {
        ZStack {
            if lessonTitles.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "list.bullet.rectangle")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(Color.fromHex("#A5A827").opacity(0.55))

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
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(Array(lessonTitles.enumerated()), id: \.offset) { index, title in
                            PendingLessonRow(
                                number: index + 1,
                                title: title,
                                removeAction: {
                                    removeLessonTitle(at: index)
                                }
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

    private var lessonInputBar: some View {
        HStack(spacing: 12) {
            TextField("Input lesson title...", text: $currentTitle)
                .font(.system(size: 17, weight: .bold))
                .focused($isTitleFieldFocused)
                .submitLabel(.done)
                .onSubmit {
                    addCurrentTitle()
                }

            Button {
                addCurrentTitle()
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 38, height: 38)
                    .background(trimmedCurrentTitle.isEmpty ? Color.black.opacity(0.16) : Color.fromHex("#A5A827"))
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

        let startIndex = roadmap.milestones.count

        for (offset, title) in finalTitles.enumerated() {
            let milestone = Milestone(
                title: title,
                explanation: "",
                photoData: nil,
                feelingScore: nil,
                isCompleted: false,
                orderIndex: startIndex + offset,
                roadmap: roadmap
            )

            roadmap.milestones.append(milestone)
            modelContext.insert(milestone)
        }

        dismiss()
    }
}
