import Foundation
import SwiftData

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

    /// 0 = very unhappy, 4 = very happy. Nil means not rated yet.
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

// MARK: - Progress helpers (centralised so views stay DRY)

extension Lesson {
    var isCompleted: Bool {
        let hasExplanation = !explanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        return hasExplanation && photoData != nil && feelingScore != nil
    }
}

extension LearningCollection {
    static let minimumLessons = 5

    var hasEnoughLessons: Bool { lessons.count >= Self.minimumLessons }

    var completedLessonsCount: Int { lessons.filter(\.isCompleted).count }

    var progress: Double {
        guard hasEnoughLessons, !lessons.isEmpty else { return 0 }
        return Double(completedLessonsCount) / Double(lessons.count)
    }

    var isFullySprouted: Bool {
        hasEnoughLessons && !lessons.isEmpty && completedLessonsCount == lessons.count
    }
}
