import SwiftUI
import SwiftData
import PhotosUI
import UIKit

// PASTE THIS FILE INTO ContentView.swift
// Then update your existing <ProjectName>App.swift to show RootView()
// and add .modelContainer(for: [LearningCollection.self, Lesson.self])

// MARK: - Models

@Model
final class LearningCollection {
    var title: String
    var summary: String
    var createdAt: Date
    var accentHex: String

    @Relationship(deleteRule: .cascade, inverse: \Lesson.collection)
    var lessons: [Lesson]

    init(
        title: String,
        summary: String,
        accentHex: String = "#A5A827",
        createdAt: Date = .now,
        lessons: [Lesson] = []
    ) {
        self.title = title
        self.summary = summary
        self.accentHex = accentHex
        self.createdAt = createdAt
        self.lessons = lessons
    }
}

@Model
final class Lesson {
    var title: String
    var explanation: String

    @Attribute(.externalStorage)
    var photoData: Data?

    /// 0 = very unhappy, 4 = very happy. Nil means the lesson has not been rated yet.
    var feelingScore: Int?

    var orderIndex: Int
    var createdAt: Date
    var collection: LearningCollection?

    init(
        title: String,
        explanation: String = "",
        photoData: Data? = nil,
        feelingScore: Int? = nil,
        orderIndex: Int = 0,
        createdAt: Date = .now,
        collection: LearningCollection? = nil
    ) {
        self.title = title
        self.explanation = explanation
        self.photoData = photoData
        self.feelingScore = feelingScore
        self.orderIndex = orderIndex
        self.createdAt = createdAt
        self.collection = collection
    }
}

// MARK: - Root

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LearningCollection.createdAt, order: .reverse) private var collections: [LearningCollection]

    @State private var selectedTab: AppTab = .collection
    @State private var showingCameraPlaceholder = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                SkyLearningBackground()

                Group {
                    switch selectedTab {
                    case .recollection:
                        RecollectionView()
                    case .collection:
                        CollectionListView(collections: collections)
                    }
                }
                .safeAreaPadding(.bottom, 92)

                FloatingTabBar(selectedTab: $selectedTab) {
                    showingCameraPlaceholder = true
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 0)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingCameraPlaceholder) {
                CameraPlaceholderView()
                    .presentationDetents([.medium])
            }
            .onAppear {
                seedExampleDataIfNeeded()
            }
        }
    }

    private func seedExampleDataIfNeeded() {
        guard collections.isEmpty else { return }

        let machining = LearningCollection(
            title: "Machining Fundamentals",
            summary: "A beginner-friendly roadmap for cutting tools, tool geometry, and machining principles.",
            accentHex: "#A5A827"
        )

        machining.lessons = [
            Lesson(
                title: "Cutting Tool Components",
                explanation: "Most cutting tools, such as planers, drills, and milling cutters, can be understood as variations or combinations of a single-point turning tool.",
                feelingScore: 3,
                orderIndex: 0,
                collection: machining
            ),
            Lesson(
                title: "Cutting Motion Direction",
                explanation: "This lesson explains the direction of the main cutting motion and the feed motion during a machining process. Use the photo area as a visual reference for the movement of the workpiece and tool.",
                feelingScore: 2,
                orderIndex: 1,
                collection: machining
            ),
            Lesson(
                title: "Tool Body and Cutting Edge",
                explanation: "Learn how the tool body, main cutting edge, and auxiliary cutting edge work together. You can edit this lesson later and replace it with your own study material.",
                feelingScore: nil,
                orderIndex: 2,
                collection: machining
            )
        ]

        modelContext.insert(machining)
    }
}

// MARK: - App Tab

enum AppTab {
    case recollection
    case collection

    var title: String {
        switch self {
        case .recollection: return "Recollection"
        case .collection: return "Collection"
        }
    }

    var icon: String {
        switch self {
        case .recollection: return "rectangle.grid.2x2"
        case .collection: return "square.stack.3d.up"
        }
    }
}

// MARK: - Collection List

struct CollectionListView: View {
    let collections: [LearningCollection]

    @State private var showingAddCollection = false
    @State private var scrollOffset: CGFloat = 0

    private let columns = [
        GridItem(.flexible(), spacing: 22),
        GridItem(.flexible(), spacing: 22)
    ]

    private var totalEntries: Int {
        collections.reduce(0) { $0 + $1.lessons.count }
    }

    private var sproutedCount: Int {
        collections.filter { collection in
            collection.lessons.count >= 5 &&
            !collection.lessons.isEmpty &&
            collection.lessons.allSatisfy { lesson in
                let hasExplanation = !lesson.explanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                let hasPhoto = lesson.photoData != nil
                let hasFeeling = lesson.feelingScore != nil
                return hasExplanation && hasPhoto && hasFeeling
            }
        }.count
    }

    private var collapseProgress: CGFloat {
        min(max(scrollOffset / 135, 0), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CollapsibleCollectionHeader(
                collectionCount: collections.count,
                entryCount: totalEntries,
                sproutedCount: sproutedCount,
                progress: collapseProgress
            ) {
                showingAddCollection = true
            }
            .padding(.horizontal, 22)
            .padding(.top, 28 - (collapseProgress * 12))
            .padding(.bottom, 18 - (collapseProgress * 10))
            .background(
                SkyLearningHeaderBackground()
                    .opacity(0.97)
                    .ignoresSafeArea(edges: .top)
            )
            .shadow(color: .black.opacity(collapseProgress * 0.08), radius: 14, y: 8)
            .animation(.snappy(duration: 0.28), value: collapseProgress)
            .zIndex(10)

            ScrollView(showsIndicators: false) {
                Color.clear
                    .frame(height: 1)
                    .background(
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: CollectionScrollOffsetKey.self,
                                value: max(0, -proxy.frame(in: .named("collectionScrollArea")).minY)
                            )
                        }
                    )

                LazyVGrid(columns: columns, spacing: 26) {
                    ForEach(collections) { collection in
                        NavigationLink {
                            CollectionDetailView(collection: collection)
                        } label: {
                            CollectionCard(collection: collection)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 22)
                .padding(.top, 20)
                .padding(.bottom, 34)
            }
            .coordinateSpace(name: "collectionScrollArea")
            .onPreferenceChange(CollectionScrollOffsetKey.self) { value in
                scrollOffset = value
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .sheet(isPresented: $showingAddCollection) {
            AddCollectionView()
        }
    }
}

struct CollectionScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct CollapsibleCollectionHeader: View {
    let collectionCount: Int
    let entryCount: Int
    let sproutedCount: Int
    let progress: CGFloat
    let addAction: () -> Void

    private var titleSize: CGFloat { 42 - (progress * 15) }
    private var plusSize: CGFloat { 48 - (progress * 12) }
    private var plusIconSize: CGFloat { 22 - (progress * 4) }
    private var statsVerticalPadding: CGFloat { 18 - (progress * 11) }
    private var spacing: CGFloat { 28 - (progress * 17) }
    private var statCornerRadius: CGFloat { 24 - (progress * 8) }

    var body: some View {
        VStack(spacing: spacing) {
            HStack(alignment: .center) {
                Text("Collections")
                    .font(.system(size: titleSize, weight: .black))
                    .foregroundStyle(Color(hex: "#A5A827"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaleEffect(1 - (progress * 0.03), anchor: .leading)

                Button(action: addAction) {
                    Image(systemName: "plus")
                        .font(.system(size: plusIconSize, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: plusSize, height: plusSize)
                        .background(Color(hex: "#A5A827"))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.14), radius: 12, y: 7)
                }
            }

            HStack(spacing: 0) {
                StatItem(value: collectionCount, title: "Collection", progress: progress)
                StatItem(value: entryCount, title: "Entries", progress: progress)
                StatItem(value: sproutedCount, title: "Sprouted", progress: progress)
            }
            .padding(.vertical, statsVerticalPadding)
            .background(Color(hex: "#A5A827"))
            .clipShape(RoundedRectangle(cornerRadius: statCornerRadius, style: .continuous))
            .scaleEffect(1 - (progress * 0.015), anchor: .top)
            .shadow(color: .black.opacity(0.05 + (progress * 0.08)), radius: 14, y: 8)
        }
    }
}

struct CollectionsTopHeader: View {
    let addAction: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            Text("Collections")
                .font(.system(size: 34, weight: .black))
                .foregroundStyle(Color(hex: "#A5A827"))

            Spacer()

            Button(action: addAction) {
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(Color(hex: "#A5A827"))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.14), radius: 12, y: 7)
            }
        }
    }
}

struct CollectionStatsBar: View {
    let collectionCount: Int
    let entryCount: Int
    let sproutedCount: Int

    var body: some View {
        HStack(spacing: 0) {
            StatItem(value: collectionCount, title: "Collection")
            StatItem(value: entryCount, title: "Entries")
            StatItem(value: sproutedCount, title: "Sprouted")
        }
        .padding(.vertical, 14)
        .background(Color(hex: "#A5A827"))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
    }
}

struct StatItem: View {
    let value: Int
    let title: String
    let progress: CGFloat

    init(value: Int, title: String, progress: CGFloat = 0) {
        self.value = value
        self.title = title
        self.progress = progress
    }

    var body: some View {
        VStack(spacing: 4 - (progress * 1.5)) {
            Text("\(value)")
                .font(.system(size: 22 - (progress * 4), weight: .black))
                .foregroundStyle(.white)

            Text(title)
                .font(.system(size: 13 - (progress * 1), weight: .medium))
                .foregroundStyle(.white.opacity(0.95))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

struct HeaderView: View {
    let eyebrow: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "gearshape.2.fill")
                    .font(.system(size: 22, weight: .bold))
                Text(eyebrow)
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundStyle(Color(hex: "#0F7897"))

            Text(title)
                .font(.system(size: 42, weight: .black))
                .foregroundStyle(.black)

            Text(subtitle)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.black.opacity(0.55))
                .lineSpacing(3)
        }
    }
}

struct AddCollectionCard: View {
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#A5A827").opacity(0.16))
                    .frame(width: 54, height: 54)

                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color(hex: "#A5A827"))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("New Collection")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.black)

                Text("Create a new learning roadmap")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.black.opacity(0.48))
            }

            Spacer()
        }
        .padding(18)
        .background(.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 20, y: 12)
    }
}

struct CollectionCard: View {
    let collection: LearningCollection

    private var completedLessonsCount: Int {
        collection.lessons.filter { lesson in
            let hasExplanation = !lesson.explanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            let hasPhoto = lesson.photoData != nil
            let hasFeeling = lesson.feelingScore != nil
            return hasExplanation && hasPhoto && hasFeeling
        }.count
    }

    private var hasEnoughLessons: Bool {
        collection.lessons.count >= 5
    }

    private var progress: Double {
        guard hasEnoughLessons, !collection.lessons.isEmpty else { return 0 }
        return Double(completedLessonsCount) / Double(collection.lessons.count)
    }

    private var progressText: String {
        hasEnoughLessons ? "\(Int(progress * 100))%" : "Need 5"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(collection.title)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(Color(hex: collection.accentHex))
                .lineLimit(1)

            Text("\(collection.lessons.count) Entries")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.black.opacity(0.38))

            HStack(spacing: 8) {
                MiniProgressBar(progress: progress, accent: Color(hex: collection.accentHex))
                    .frame(height: 5)

                Text(progressText)
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(hasEnoughLessons ? Color(hex: collection.accentHex) : .black.opacity(0.35))
                    .frame(width: 42, alignment: .trailing)
            }
            .padding(.top, 8)

            Spacer(minLength: 0)

            SproutMascot(accent: hasEnoughLessons ? Color(hex: collection.accentHex) : Color.black.opacity(0.16))
                .frame(width: 108, height: 92)
                .frame(maxWidth: .infinity, alignment: .center)
                .offset(y: 18)
        }
        .padding(.top, 18)
        .padding(.horizontal, 14)
        .frame(height: 190)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        .shadow(color: .black.opacity(0.13), radius: 12, x: 0, y: 7)
        .clipped()
    }
}

struct MiniProgressBar: View {
    let progress: Double
    let accent: Color

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.black.opacity(0.08))

                Capsule()
                    .fill(accent)
                    .frame(width: proxy.size.width * progress)
            }
        }
        .frame(height: 5)
    }
}

struct SproutMascot: View {
    let accent: Color

    var body: some View {
        ZStack(alignment: .bottom) {
            Circle()
                .fill(accent)
                .frame(width: 86, height: 86)
                .offset(y: 30)

            HStack(spacing: 12) {
                EyeView()
                EyeView()
            }
            .offset(y: 4)

            Capsule()
                .fill(.white)
                .frame(width: 8, height: 28)
                .offset(x: 31, y: 17)

            VStack(spacing: -2) {
                LeafShape()
                    .fill(accent)
                    .frame(width: 22, height: 38)
                    .rotationEffect(.degrees(-34))
                    .offset(x: -8, y: 8)

                LeafShape()
                    .fill(accent)
                    .frame(width: 22, height: 42)
                    .rotationEffect(.degrees(32))
                    .offset(x: 14, y: -16)
            }
            .offset(y: -48)
        }
    }
}

struct EyeView: View {
    var body: some View {
        Circle()
            .fill(.white)
            .frame(width: 13, height: 13)
            .overlay(alignment: .center) {
                Circle()
                    .fill(Color.black.opacity(0.45))
                    .frame(width: 5, height: 5)
            }
    }
}

struct LeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control1: CGPoint(x: rect.minX - rect.width * 0.15, y: rect.height * 0.62),
            control2: CGPoint(x: rect.minX, y: rect.height * 0.10)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control1: CGPoint(x: rect.maxX, y: rect.height * 0.10),
            control2: CGPoint(x: rect.maxX + rect.width * 0.15, y: rect.height * 0.62)
        )
        return path
    }
}

// MARK: - Collection Detail

struct CollectionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var collection: LearningCollection
    @State private var showingAddLesson = false
    @State private var showingEditCollection = false
    @State private var showingDeleteAlert = false

    var sortedLessons: [Lesson] {
        collection.lessons.sorted { first, second in
            let firstCompleted = isLessonCompleted(first)
            let secondCompleted = isLessonCompleted(second)

            if firstCompleted != secondCompleted {
                return !firstCompleted && secondCompleted
            }

            if firstCompleted && secondCompleted {
                return first.orderIndex > second.orderIndex
            }

            return first.orderIndex < second.orderIndex
        }
    }

    private func isLessonCompleted(_ lesson: Lesson) -> Bool {
        let hasExplanation = !lesson.explanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasPhoto = lesson.photoData != nil
        let hasFeeling = lesson.feelingScore != nil

        return hasExplanation && hasPhoto && hasFeeling
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

                        CollectionProgressCard(
                            lessons: collection.lessons,
                            accent: Color(hex: collection.accentHex)
                        )

                        VStack(spacing: 14) {
                            ForEach(sortedLessons) { lesson in
                                NavigationLink {
                                    LessonDetailView(lesson: lesson, accent: Color(hex: collection.accentHex))
                                } label: {
                                    LessonCard(
                                        index: lesson.orderIndex + 1,
                                        lesson: lesson,
                                        accent: Color(hex: collection.accentHex)
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
    let lessons: [Lesson]
    let accent: Color

    private let minimumLessons = 5

    private var completedLessonsCount: Int {
        lessons.filter { lesson in
            let hasExplanation = !lesson.explanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            let hasPhoto = lesson.photoData != nil
            let hasFeeling = lesson.feelingScore != nil
            return hasExplanation && hasPhoto && hasFeeling
        }.count
    }

    private var hasEnoughLessons: Bool {
        lessons.count >= minimumLessons
    }

    private var progress: Double {
        guard hasEnoughLessons, !lessons.isEmpty else { return 0 }
        return Double(completedLessonsCount) / Double(lessons.count)
    }

    private var remainingLessonsNeeded: Int {
        max(minimumLessons - lessons.count, 0)
    }

    private var remainingToComplete: Int {
        max(lessons.count - completedLessonsCount, 0)
    }

    private var titleText: String {
        if !hasEnoughLessons { return "Not Enough Lessons" }
        return progress >= 1 ? "Fully Sprouted" : "Sprout"
    }

    private var subtitleText: String {
        if !hasEnoughLessons {
            return "Add \(remainingLessonsNeeded) more lesson\(remainingLessonsNeeded == 1 ? "" : "s") to activate progress"
        }

        if progress >= 1 {
            return "Collection complete"
        }

        return "\(remainingToComplete) of \(lessons.count) lessons left"
    }

    private var percentText: String {
        hasEnoughLessons ? "\(Int(progress * 100))%" : "Invalid"
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 7) {
                Text(titleText)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(hasEnoughLessons ? accent : .black.opacity(0.38))

                Text(subtitleText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.black.opacity(0.38))
                    .lineLimit(2)

                HStack(spacing: 10) {
                    MiniProgressBar(progress: progress, accent: hasEnoughLessons ? accent : Color.black.opacity(0.18))
                        .frame(height: 6)

                    Text(percentText)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(hasEnoughLessons ? .black.opacity(0.32) : .black.opacity(0.28))
                }
                .padding(.top, 4)
            }

            Spacer(minLength: 6)

            SproutMascot(accent: hasEnoughLessons ? accent : Color.black.opacity(0.16))
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

struct LessonAddButton: View {
    let accent: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(accent)

            Text("Add Lesson")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.black)

            Spacer()

            Text("Title  •  Detail  •  Content")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.black.opacity(0.35))
        }
        .padding(18)
        .background(.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 16, y: 10)
    }
}

struct LessonCard: View {
    let index: Int
    let lesson: Lesson
    let accent: Color

    private var hasExplanation: Bool {
        !lesson.explanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var isCompleted: Bool {
        hasExplanation && lesson.photoData != nil && lesson.feelingScore != nil
    }

    private var statusText: String {
        isCompleted ? "Completed" : "Incomplete"
    }

    private var statusIcon: String {
        isCompleted ? "checkmark.circle.fill" : "circle"
    }

    private var statusColor: Color {
        isCompleted ? accent : .black.opacity(0.34)
    }

    private var cardBackground: Color {
        isCompleted ? .white : .white.opacity(0.68)
    }

    private var tileBackground: Color {
        isCompleted ? accent.opacity(0.14) : .black.opacity(0.055)
    }

    private var tileTextColor: Color {
        isCompleted ? accent : .black.opacity(0.28)
    }

    private var borderColor: Color {
        isCompleted ? accent.opacity(0.24) : .black.opacity(0.035)
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(tileBackground)
                    .frame(width: 72, height: 72)

                VStack(spacing: 2) {
                    Text(String(format: "%02d", index))
                        .font(.system(size: 18, weight: .black))
                    Text("LESSON")
                        .font(.system(size: 8, weight: .black))
                }
                .foregroundStyle(tileTextColor)
            }

            VStack(alignment: .leading, spacing: 7) {
                Text(lesson.title)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(.black.opacity(isCompleted ? 1 : 0.78))
                    .lineLimit(2)

                Text(hasExplanation ? lesson.explanation : "Tap to add explanation")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.black.opacity(hasExplanation ? 0.52 : 0.30))
                    .lineLimit(2)

                HStack(spacing: 7) {
                    LowKeyFeelingPreview(score: lesson.feelingScore)

                    Image(systemName: statusIcon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(statusColor)

                    Text(statusText)
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(statusColor)
                }
                .padding(.top, 2)
            }

            Spacer(minLength: 6)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.black.opacity(0.20))
        }
        .padding(14)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
        }
        .shadow(color: .black.opacity(isCompleted ? 0.07 : 0.035), radius: 14, y: 8)
    }
}

struct LowKeyFeelingPreview: View {
    let score: Int?

    private var symbolName: String {
        guard let score else { return "face.smiling" }

        switch score {
        case 0: return "face.dashed"
        case 1: return "face.smiling.inverse"
        case 2: return "face.smiling"
        case 3: return "face.smiling.fill"
        default: return "face.smiling.fill"
        }
    }

    private var iconOpacity: Double {
        score == nil ? 0.20 : 0.42
    }

    var body: some View {
        Image(systemName: symbolName)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.black.opacity(iconOpacity))
            .frame(width: 18, height: 18)
    }
}

// MARK: - Lesson Detail

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
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Lesson Title")
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(.black.opacity(0.35))

                            TextField("Lesson title", text: $lesson.title, axis: .vertical)
                                .font(.system(size: 28, weight: .black))
                                .foregroundStyle(.black)
                                .lineLimit(1...3)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Photo")
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(.black.opacity(0.35))

                            LessonPhotoPicker(
                                photoData: lesson.photoData,
                                accent: accent,
                                selectedPhotoItem: $selectedPhotoItem,
                                removeAction: { lesson.photoData = nil }
                            )
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Explanation")
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(.black.opacity(0.35))

                            ExpandingExplanationField(text: $lesson.explanation)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            Text("How did you feel after finishing this lesson?")
                                .font(.system(size: 13, weight: .black))
                                .foregroundStyle(.black.opacity(0.35))

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
                    await MainActor.run {
                        lesson.photoData = data
                    }
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
}

struct ExpandingExplanationField: View {
    @Binding var text: String

    var body: some View {
        TextField("Write the lesson explanation here...", text: $text, axis: .vertical)
            .font(.system(size: 17, weight: .regular))
            .foregroundStyle(.black.opacity(0.82))
            .lineLimit(6...)
            .textFieldStyle(.plain)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(Color.black.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

struct LessonPhotoPicker: View {
    let photoData: Data?
    let accent: Color
    @Binding var selectedPhotoItem: PhotosPickerItem?
    let removeAction: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.black.opacity(0.06))
                        .frame(height: 190)

                    if let photoData,
                       let image = UIImage(data: photoData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 190)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    } else {
                        VStack(spacing: 10) {
                            Image(systemName: "plus")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 70, height: 70)
                                .background(accent)
                                .clipShape(Circle())

                            Text("Add Photo")
                                .font(.system(size: 15, weight: .black))
                                .foregroundStyle(.black.opacity(0.45))
                        }
                    }
                }
            }
            .buttonStyle(.plain)

            if photoData != nil {
                Button(role: .destructive, action: removeAction) {
                    Text("Remove Photo")
                        .font(.system(size: 13, weight: .bold))
                }
            }
        }
    }
}

struct FeelingPicker: View {
    @Binding var selectedScore: Int?
    let accent: Color

    var body: some View {
        HStack(spacing: 13) {
            ForEach(0..<5, id: \.self) { score in
                Button {
                    withAnimation(.snappy(duration: 0.22)) {
                        selectedScore = score
                    }
                } label: {
                    FeelingIcon(score: score, isSelected: selectedScore == score, accent: accent)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.035))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

struct FeelingPreview: View {
    let score: Int?

    var body: some View {
        if let score {
            FeelingIcon(score: score, isSelected: true, accent: Color(hex: "#A5A827"))
                .frame(width: 22, height: 22)
        } else {
            Image(systemName: "face.smiling.inverse")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.black.opacity(0.25))
        }
    }
}

struct FeelingIcon: View {
    let score: Int
    let isSelected: Bool
    let accent: Color

    private var faceColor: Color {
        isSelected ? accent : Color.black.opacity(0.18)
    }

    private var mouth: String {
        switch score {
        case 0: return "frown"
        case 1: return "neutral"
        case 2: return "smallSmile"
        case 3: return "smile"
        default: return "bigSmile"
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Circle()
                .fill(faceColor)
                .frame(width: 44, height: 44)
                .scaleEffect(isSelected ? 1.08 : 1)

            VStack(spacing: -2) {
                LeafShape()
                    .fill(faceColor)
                    .frame(width: 13, height: 22)
                    .rotationEffect(.degrees(-34))
                    .offset(x: -5, y: 5)

                LeafShape()
                    .fill(faceColor)
                    .frame(width: 13, height: 24)
                    .rotationEffect(.degrees(32))
                    .offset(x: 8, y: -10)
            }
            .offset(y: -34)
            .opacity(score >= 2 ? 1 : 0.45)

            HStack(spacing: 7) {
                Circle()
                    .fill(.white.opacity(0.95))
                    .frame(width: 6, height: 6)
                Circle()
                    .fill(.white.opacity(0.95))
                    .frame(width: 6, height: 6)
            }
            .offset(y: -23)

            MouthShape(kind: mouth)
                .stroke(.white.opacity(0.95), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .frame(width: 18, height: 10)
                .offset(y: -10)
        }
        .frame(width: 50, height: 58)
    }
}

struct MouthShape: Shape {
    let kind: String

    func path(in rect: CGRect) -> Path {
        var path = Path()

        switch kind {
        case "frown":
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY), control: CGPoint(x: rect.midX, y: rect.minY))
        case "neutral":
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        case "smallSmile":
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY), control: CGPoint(x: rect.midX, y: rect.maxY))
        case "smile":
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY), control: CGPoint(x: rect.midX, y: rect.maxY))
        default:
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY), control: CGPoint(x: rect.midX, y: rect.maxY + rect.height * 0.25))
        }

        return path
    }
}

struct LessonDiagramHero: View {
    let accent: Color

    var body: some View {
        VStack(spacing: 14) {
            HStack(spacing: 18) {
                MiniToolDiagram(kind: .lathe, accent: accent)
                MiniToolDiagram(kind: .drill, accent: accent)
            }

            HStack(spacing: 18) {
                MiniToolDiagram(kind: .planer, accent: accent)
                MiniToolDiagram(kind: .milling, accent: accent)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(.black.opacity(0.06), lineWidth: 1)
        }
    }
}

struct TextBlockView: View {
    let text: String
    let accent: Color

    private var paragraphs: [String] {
        text.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(paragraphs.enumerated()), id: \.offset) { index, paragraph in
                HStack(alignment: .top, spacing: 10) {
                    Circle()
                        .fill(index == 0 ? .blue : accent)
                        .frame(width: 7, height: 7)
                        .padding(.top, 9)

                    Text(paragraph)
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundStyle(index == 0 ? .blue : .black)
                        .lineSpacing(5)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

// MARK: - Create & Edit Forms

struct AddCollectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title = ""
    @State private var summary = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Collection") {
                    TextField("Title", text: $title)
                    TextField("Summary", text: $summary, axis: .vertical)
                        .lineLimit(3...5)
                }
            }
            .navigationTitle("New Collection")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let collection = LearningCollection(
                            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                            summary: summary.trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                        modelContext.insert(collection)
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

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
                Color(hex: "#F4F4F8")
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
                        .foregroundStyle(titlesToSave.isEmpty ? .black.opacity(0.25) : Color(hex: "#A5A827"))
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
                explanation: "",
                photoData: nil,
                feelingScore: nil,
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

struct EditLessonView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var lesson: Lesson

    var body: some View {
        NavigationStack {
            Form {
                Section("Lesson") {
                    TextField("Title", text: $lesson.title)
                    TextField("Explanation", text: $lesson.explanation, axis: .vertical)
                        .lineLimit(6...12)
                }
            }
            .navigationTitle("Edit Lesson")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Recollection Placeholder

struct RecollectionView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                HeaderView(
                    eyebrow: "Review Center",
                    title: "Recollection",
                    subtitle: "Use this area later for reviewed lessons, bookmarks, or topics that need more practice."
                )
                .padding(.top, 28)

                VStack(spacing: 16) {
                    Image(systemName: "rectangle.grid.2x2")
                        .font(.system(size: 42, weight: .bold))
                        .foregroundStyle(Color(hex: "#A5A827"))

                    Text("No recollection items yet")
                        .font(.system(size: 21, weight: .black))
                        .foregroundStyle(.black)

                    Text("For the first version, the app focuses on creating collections and lessons first.")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.black.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .frame(maxWidth: .infinity)
                .padding(28)
                .background(.white.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .shadow(color: .black.opacity(0.08), radius: 18, y: 12)
            }
            .padding(.horizontal, 20)
        }
    }
}

struct CameraPlaceholderView: View {
    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: "#A5A827").opacity(0.14))
                    .frame(width: 84, height: 84)

                Image(systemName: "camera")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Color(hex: "#A5A827"))
            }

            Text("Camera Placeholder")
                .font(.system(size: 23, weight: .black))

            Text("Assets and scan/photo features are intentionally ignored for now. Later, this section can be connected to image import, camera capture, or OCR.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.black.opacity(0.55))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 30)
        }
    }
}

// MARK: - Bottom Tab Bar

struct FloatingTabBar: View {
    @Binding var selectedTab: AppTab
    let cameraAction: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            TabBarNotchedShape(
                notchWidth: 104,
                notchDepth: 40,
                cornerRadius: 30
            )
            .fill(.white.opacity(0.97))
            .frame(height: 74)
            .shadow(color: .black.opacity(0.12), radius: 18, y: 8)
            .padding(.top, 32)

            HStack(spacing: 0) {
                TabButton(tab: .recollection, selectedTab: $selectedTab)
                Spacer(minLength: 86)
                TabButton(tab: .collection, selectedTab: $selectedTab)
            }
            .padding(.horizontal, 22)
            .padding(.top, 50)
            .frame(height: 106)

            Button(action: cameraAction) {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 66, height: 66)
                        .shadow(color: .black.opacity(0.14), radius: 12, y: 6)

                    Circle()
                        .stroke(.black.opacity(0.06), lineWidth: 1)
                        .frame(width: 66, height: 66)

                    Image(systemName: "camera")
                        .font(.system(size: 23, weight: .bold))
                        .foregroundStyle(.black.opacity(0.38))
                }
            }
            .offset(y: 14)
        }
        .frame(height: 112)
    }
}

struct TabBarNotchedShape: Shape {
    var notchWidth: CGFloat
    var notchDepth: CGFloat
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let radius = min(cornerRadius, height / 2)

        let centerX = width / 2
        let notchHalfWidth = notchWidth / 2
        let notchStartX = centerX - notchHalfWidth
        let notchEndX = centerX + notchHalfWidth

        var path = Path()

        path.move(to: CGPoint(x: radius, y: 0))
        path.addLine(to: CGPoint(x: notchStartX, y: 0))

        path.addCurve(
            to: CGPoint(x: centerX, y: notchDepth),
            control1: CGPoint(x: notchStartX + 20, y: 0),
            control2: CGPoint(x: centerX - 34, y: notchDepth)
        )

        path.addCurve(
            to: CGPoint(x: notchEndX, y: 0),
            control1: CGPoint(x: centerX + 34, y: notchDepth),
            control2: CGPoint(x: notchEndX - 20, y: 0)
        )

        path.addLine(to: CGPoint(x: width - radius, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: width, y: radius),
            control: CGPoint(x: width, y: 0)
        )

        path.addLine(to: CGPoint(x: width, y: height - radius))
        path.addQuadCurve(
            to: CGPoint(x: width - radius, y: height),
            control: CGPoint(x: width, y: height)
        )

        path.addLine(to: CGPoint(x: radius, y: height))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: height - radius),
            control: CGPoint(x: 0, y: height)
        )

        path.addLine(to: CGPoint(x: 0, y: radius))
        path.addQuadCurve(
            to: CGPoint(x: radius, y: 0),
            control: CGPoint(x: 0, y: 0)
        )

        path.closeSubpath()
        return path
    }
}

struct TabButton: View {
    let tab: AppTab
    @Binding var selectedTab: AppTab

    var isSelected: Bool { selectedTab == tab }

    var body: some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 19, weight: .bold))

                Text(tab.title)
                    .font(.system(size: 10, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(isSelected ? Color(hex: "#A5A827") : .black.opacity(0.28))
        }
    }
}

// MARK: - Decorative Views

struct SkyLearningBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "#DDF5FF"),
                Color(hex: "#F7FBFF"),
                Color(hex: "#EAF4F7")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(.white.opacity(0.5))
                .frame(width: 230, height: 230)
                .blur(radius: 24)
                .offset(x: 80, y: -70)
        }
        .overlay(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 999, style: .continuous)
                .fill(Color.white.opacity(0.34))
                .frame(width: 220, height: 70)
                .blur(radius: 10)
                .offset(x: -40, y: 92)
        }
    }
}

struct SkyLearningHeaderBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "#DDF5FF"),
                Color(hex: "#EEF9FF")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(.white.opacity(0.42))
                .frame(width: 220, height: 220)
                .blur(radius: 24)
                .offset(x: 80, y: -76)
        }
    }
}

struct PlaceholderDiagramStrip: View {
    let accent: Color

    var body: some View {
        HStack(spacing: 10) {
            ForEach(MiniToolKind.allCases, id: \.self) { kind in
                MiniToolDiagram(kind: kind, accent: accent)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

enum MiniToolKind: CaseIterable {
    case lathe
    case drill
    case planer
    case milling
}

struct MiniToolDiagram: View {
    let kind: MiniToolKind
    let accent: Color

    var body: some View {
        Canvas { context, size in
            let stroke = StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round)
            let black = Color.black.opacity(0.82)
            let muted = Color.black.opacity(0.28)

            switch kind {
            case .lathe:
                var shaft = Path()
                shaft.move(to: CGPoint(x: size.width * 0.08, y: size.height * 0.50))
                shaft.addLine(to: CGPoint(x: size.width * 0.88, y: size.height * 0.50))
                context.stroke(shaft, with: .color(black), style: stroke)

                var cylinder = Path()
                cylinder.addRoundedRect(in: CGRect(x: size.width * 0.18, y: size.height * 0.38, width: size.width * 0.46, height: size.height * 0.24), cornerSize: CGSize(width: 8, height: 8))
                context.stroke(cylinder, with: .color(black), style: stroke)

                var cutter = Path()
                cutter.move(to: CGPoint(x: size.width * 0.55, y: size.height * 0.30))
                cutter.addLine(to: CGPoint(x: size.width * 0.67, y: size.height * 0.50))
                cutter.addLine(to: CGPoint(x: size.width * 0.57, y: size.height * 0.72))
                context.stroke(cutter, with: .color(accent), style: stroke)

            case .drill:
                var drill = Path()
                drill.move(to: CGPoint(x: size.width * 0.50, y: size.height * 0.12))
                drill.addCurve(to: CGPoint(x: size.width * 0.50, y: size.height * 0.72), control1: CGPoint(x: size.width * 0.32, y: size.height * 0.26), control2: CGPoint(x: size.width * 0.68, y: size.height * 0.48))
                drill.addCurve(to: CGPoint(x: size.width * 0.50, y: size.height * 0.12), control1: CGPoint(x: size.width * 0.32, y: size.height * 0.48), control2: CGPoint(x: size.width * 0.68, y: size.height * 0.26))
                context.stroke(drill, with: .color(black), style: stroke)

                var block = Path()
                block.addRect(CGRect(x: size.width * 0.22, y: size.height * 0.68, width: size.width * 0.56, height: size.height * 0.20))
                context.stroke(block, with: .color(muted), style: stroke)

            case .planer:
                var block = Path()
                block.addRoundedRect(in: CGRect(x: size.width * 0.12, y: size.height * 0.56, width: size.width * 0.72, height: size.height * 0.25), cornerSize: CGSize(width: 3, height: 3))
                context.stroke(block, with: .color(black), style: stroke)

                var tool = Path()
                tool.move(to: CGPoint(x: size.width * 0.46, y: size.height * 0.16))
                tool.addLine(to: CGPoint(x: size.width * 0.58, y: size.height * 0.56))
                tool.addLine(to: CGPoint(x: size.width * 0.42, y: size.height * 0.56))
                tool.closeSubpath()
                context.stroke(tool, with: .color(accent), style: stroke)

                var arrow = Path()
                arrow.move(to: CGPoint(x: size.width * 0.20, y: size.height * 0.46))
                arrow.addLine(to: CGPoint(x: size.width * 0.76, y: size.height * 0.46))
                context.stroke(arrow, with: .color(muted), style: stroke)

            case .milling:
                var disc = Path()
                disc.addEllipse(in: CGRect(x: size.width * 0.22, y: size.height * 0.18, width: size.width * 0.42, height: size.height * 0.42))
                context.stroke(disc, with: .color(black), style: stroke)

                for i in 0..<8 {
                    let angle = Double(i) * .pi / 4
                    let center = CGPoint(x: size.width * 0.43, y: size.height * 0.39)
                    var tooth = Path()
                    tooth.move(to: CGPoint(x: center.x + cos(angle) * size.width * 0.21, y: center.y + sin(angle) * size.height * 0.21))
                    tooth.addLine(to: CGPoint(x: center.x + cos(angle) * size.width * 0.30, y: center.y + sin(angle) * size.height * 0.30))
                    context.stroke(tooth, with: .color(accent), style: stroke)
                }

                var base = Path()
                base.addRect(CGRect(x: size.width * 0.20, y: size.height * 0.64, width: size.width * 0.62, height: size.height * 0.16))
                context.stroke(base, with: .color(muted), style: stroke)
            }
        }
        .padding(8)
        .background(Color.black.opacity(0.025))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Helpers

extension Color {
    init(hex: String) {
        let cleanedHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanedHex).scanHexInt64(&int)

        let red: UInt64
        let green: UInt64
        let blue: UInt64

        switch cleanedHex.count {
        case 3:
            red = (int >> 8) * 17
            green = (int >> 4 & 0xF) * 17
            blue = (int & 0xF) * 17
        case 6:
            red = int >> 16
            green = int >> 8 & 0xFF
            blue = int & 0xFF
        default:
            red = 165
            green = 168
            blue = 39
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: 1
        )
    }
}

#Preview {
    RootView()
        .modelContainer(for: [LearningCollection.self, Lesson.self], inMemory: true)
}
