import SwiftUI
import SwiftData

struct CollectionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var collection: LearningCollection

    @State private var showingAddLesson = false
    @State private var showingEditCollection = false
    @State private var showingDeleteAlert = false

    private var accent: Color { Color(hex: collection.accentHex) }

    private var sortedLessons: [Lesson] {
        collection.lessons.sorted { first, second in
            if first.isCompleted != second.isCompleted {
                return !first.isCompleted && second.isCompleted
            }
            if first.isCompleted && second.isCompleted {
                return first.orderIndex > second.orderIndex
            }
            return first.orderIndex < second.orderIndex
        }
    }

    var body: some View {
        ZStack {
            SkyLearningBackground()

            VStack(spacing: 0) {
                CollectionDetailTopBar(
                    title: collection.title,
                    onBack: { dismiss() },
                    onAdd: { showingAddLesson = true }
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
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("\(collection.lessons.count) Entries")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.black.opacity(0.45))

                            Text(collection.title)
                                .font(.system(size: 34, weight: .black))
                                .foregroundStyle(.black)

                            Text(collection.summary)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.black.opacity(0.55))
                                .lineSpacing(3)
                        }
                        .padding(.horizontal, 4)

                        CollectionProgressCard(collection: collection)

                        VStack(spacing: 14) {
                            ForEach(sortedLessons) { lesson in
                                NavigationLink {
                                    LessonDetailView(lesson: lesson, accent: accent)
                                } label: {
                                    LessonCard(
                                        index: lesson.orderIndex + 1,
                                        lesson: lesson,
                                        accent: accent
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Text("Delete Collection")
                                .font(.system(size: 15, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(.white.opacity(0.9))
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .safeAreaPadding(.bottom, 28)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingAddLesson) {
            AddLessonView(collection: collection)
        }
        .sheet(isPresented: $showingEditCollection) {
            EditCollectionView(collection: collection)
        }
        .alert("Delete collection?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                modelContext.delete(collection)
                dismiss()
            }
        } message: {
            Text("All lessons inside this collection will also be deleted.")
        }
    }
}

struct CollectionDetailTopBar: View {
    let title: String
    let onBack: () -> Void
    let onAdd: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 54, height: 54)
                    .background(.white.opacity(0.9))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
            }

            Spacer()

            Text(title)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(.black.opacity(0.82))
                .lineLimit(1)

            Spacer()

            Button(action: onAdd) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(Color(hex: "#A5A827"))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.10), radius: 10, y: 5)
            }
        }
    }
}

struct CollectionProgressCard: View {
    let collection: LearningCollection

    private var accent: Color { Color(hex: collection.accentHex) }
    private var lessonCount: Int { collection.lessons.count }
    private var remainingNeeded: Int { max(LearningCollection.minimumLessons - lessonCount, 0) }
    private var remainingToComplete: Int { max(lessonCount - collection.completedLessonsCount, 0) }

    private var titleText: String {
        if !collection.hasEnoughLessons { return "Not Enough Lessons" }
        return collection.isFullySprouted ? "Fully Sprouted" : "Sprout"
    }

    private var subtitleText: String {
        if !collection.hasEnoughLessons {
            return "Add \(remainingNeeded) more lesson\(remainingNeeded == 1 ? "" : "s") to activate progress"
        }
        if collection.isFullySprouted { return "Collection complete" }
        return "\(remainingToComplete) of \(lessonCount) lessons left"
    }

    private var percentText: String {
        collection.hasEnoughLessons ? "\(Int(collection.progress * 100))%" : "Invalid"
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 7) {
                Text(titleText)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(collection.hasEnoughLessons ? accent : .black.opacity(0.38))

                Text(subtitleText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.black.opacity(0.38))
                    .lineLimit(2)

                HStack(spacing: 10) {
                    MiniProgressBar(
                        progress: collection.progress,
                        accent: collection.hasEnoughLessons ? accent : Color.black.opacity(0.18)
                    )
                    .frame(height: 6)

                    Text(percentText)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(collection.hasEnoughLessons ? .black.opacity(0.32) : .black.opacity(0.28))
                }
                .padding(.top, 4)
            }

            Spacer(minLength: 6)

            SproutMascot(accent: collection.hasEnoughLessons ? accent : Color.black.opacity(0.16))
                .frame(width: 70, height: 54)
                .offset(y: 12)
        }
        .padding(.horizontal, 22)
        .frame(height: 118)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.10), radius: 14, y: 8)
        .clipped()
    }
}
