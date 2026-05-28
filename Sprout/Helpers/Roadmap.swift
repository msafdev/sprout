//
//  Roadmap.swift
//  Sprout
//

import Foundation
import SwiftData

@Model
final class Roadmap {
    var id: UUID = UUID()
    var title: String = ""
    var goalDescription: String = ""
    var colorHex: String = "#34C759"
    var createdAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \Milestone.roadmap)
    var milestones: [Milestone] = []

    init(
        title: String,
        goalDescription: String = "",
        colorHex: String = "#34C759",
        createdAt: Date = Date()
    ) {
        self.id = UUID()
        self.title = title
        self.goalDescription = goalDescription
        self.colorHex = colorHex
        self.createdAt = createdAt
        self.milestones = []
    }
}

// MARK: - Roadmap Progress Logic

extension Roadmap {
    var minimumMilestonesForProgress: Int {
        5
    }

    var hasEnoughMilestones: Bool {
        milestones.count >= minimumMilestonesForProgress
    }

    var completedMilestonesCount: Int {
        milestones.filter { $0.isCompletedForProgress }.count
    }

    var progress: Double {
        guard hasEnoughMilestones, !milestones.isEmpty else { return 0 }
        return Double(completedMilestonesCount) / Double(milestones.count)
    }

    var isFullySprouted: Bool {
        hasEnoughMilestones && progress >= 1
    }

    var remainingMilestonesNeeded: Int {
        max(minimumMilestonesForProgress - milestones.count, 0)
    }

    var remainingMilestonesToComplete: Int {
        max(milestones.count - completedMilestonesCount, 0)
    }

    var sortedMilestones: [Milestone] {
        milestones.sorted { first, second in
            let firstCompleted = first.isCompletedForProgress
            let secondCompleted = second.isCompletedForProgress

            if firstCompleted != secondCompleted {
                return !firstCompleted && secondCompleted
            }

            if firstCompleted && secondCompleted {
                return first.orderIndex > second.orderIndex
            }

            return first.orderIndex < second.orderIndex
        }
    }
}

@Model
final class Milestone {
    var id: UUID = UUID()

    // Lesson title
    var title: String = ""

    // Lesson explanation/content
    var explanation: String = ""

    // Lesson photo
    @Attribute(.externalStorage)
    var photoData: Data?

    // 0 = very unhappy, 4 = very happy
    var feelingScore: Int?

    // Kept from your team's original model name
    var isCompleted: Bool = false

    // Needed for ordering lessons inside roadmap
    var orderIndex: Int = 0

    // Needed for sorting and recollection
    var createdAt: Date = Date()

    // Used by Recollection feature
    var completedAt: Date?

    var roadmap: Roadmap?

    init(
        title: String,
        explanation: String = "",
        photoData: Data? = nil,
        feelingScore: Int? = nil,
        isCompleted: Bool = false,
        orderIndex: Int = 0,
        createdAt: Date = Date(),
        completedAt: Date? = nil,
        roadmap: Roadmap? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.explanation = explanation
        self.photoData = photoData
        self.feelingScore = feelingScore
        self.isCompleted = isCompleted
        self.orderIndex = orderIndex
        self.createdAt = createdAt
        self.completedAt = completedAt
        self.roadmap = roadmap
    }
}

// MARK: - Milestone Completion Logic

extension Milestone {
    var hasExplanation: Bool {
        !explanation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var hasPhoto: Bool {
        photoData != nil
    }

    var hasFeeling: Bool {
        feelingScore != nil
    }

    var isReadyToComplete: Bool {
        hasExplanation && hasPhoto && hasFeeling
    }

    var isCompletedForProgress: Bool {
        isCompleted && isReadyToComplete
    }

    func markCompleted() {
        guard isReadyToComplete else { return }

        isCompleted = true

        if completedAt == nil {
            completedAt = Date()
        }
    }

    func markIncomplete() {
        isCompleted = false
        completedAt = nil
    }
}
