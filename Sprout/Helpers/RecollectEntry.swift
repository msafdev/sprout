//
//  RecollectEntry.swift
//  Sprout
//

import SwiftUI

struct RecollectEntry: Identifiable {
    var id: UUID = UUID()
    var date: Date
    var items: [EntryItem]

    // Helper properties mapped to first item for calendar grid preview
    var count: Int { items.count }
    var imageName: String { items.first?.imageName ?? "placehold-1" }
    var bgGradientStart: String { items.first?.bgGradientStart ?? "#FF5E62" }
    var bgGradientEnd: String { items.first?.bgGradientEnd ?? "#FF9966" }

    var startColor: Color {
        Color.fromHex(bgGradientStart)
    }

    var endColor: Color {
        Color.fromHex(bgGradientEnd)
    }

    init(date: Date, items: [EntryItem]) {
        self.id = UUID()
        self.date = date
        self.items = items
    }
}

struct EntryItem: Identifiable, Codable {
    var id: UUID = UUID()

    // Connects recollection item back to the real lesson/milestone data.
    var milestoneID: UUID

    var imageName: String
    var title: String
    var description: String

    var photoData: Data?
    var feelingScore: Int?

    var bgGradientStart: String
    var bgGradientEnd: String

    init(
        milestoneID: UUID = UUID(),
        imageName: String,
        title: String,
        description: String,
        photoData: Data? = nil,
        feelingScore: Int? = nil,
        bgGradientStart: String,
        bgGradientEnd: String
    ) {
        self.id = milestoneID
        self.milestoneID = milestoneID
        self.imageName = imageName
        self.title = title
        self.description = description
        self.photoData = photoData
        self.feelingScore = feelingScore
        self.bgGradientStart = bgGradientStart
        self.bgGradientEnd = bgGradientEnd
    }

    init(milestone: Milestone) {
        self.id = milestone.id
        self.milestoneID = milestone.id
        self.imageName = "placehold-1"
        self.title = milestone.title
        self.description = milestone.explanation
        self.photoData = milestone.photoData
        self.feelingScore = milestone.feelingScore
        self.bgGradientStart = milestone.roadmap?.colorHex ?? "#A5A827"
        self.bgGradientEnd = "#DDF5FF"
    }
}

// MARK: - Recollection Builder

struct RecollectionBuilder {
    static func entries(from roadmaps: [Roadmap], calendar: Calendar = .current) -> [RecollectEntry] {
        let milestones = roadmaps.flatMap { $0.milestones }
        return entries(from: milestones, calendar: calendar)
    }

    static func entries(from milestones: [Milestone], calendar: Calendar = .current) -> [RecollectEntry] {
        let completedMilestones = milestones
            .filter { $0.isCompletedForProgress }
            .sorted {
                let firstDate = $0.completedAt ?? $0.createdAt
                let secondDate = $1.completedAt ?? $1.createdAt
                return firstDate > secondDate
            }

        let groupedByDay = Dictionary(grouping: completedMilestones) { milestone in
            calendar.startOfDay(for: milestone.completedAt ?? milestone.createdAt)
        }

        return groupedByDay
            .map { date, milestones in
                let items = milestones.map { EntryItem(milestone: $0) }
                return RecollectEntry(date: date, items: items)
            }
            .sorted { $0.date > $1.date }
    }
}

// MARK: - Helper to convert Hex to Color

extension Color {
    static func fromHex(_ hex: String) -> Color {
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)

        if cleanHex.hasPrefix("#") {
            cleanHex.removeFirst()
        }

        var rgb: UInt64 = 0
        guard Scanner(string: cleanHex).scanHexInt64(&rgb) else { return .gray }

        let r, g, b, a: Double

        if cleanHex.count == 6 {
            r = Double((rgb >> 16) & 0xFF) / 255.0
            g = Double((rgb >> 8) & 0xFF) / 255.0
            b = Double(rgb & 0xFF) / 255.0
            a = 1.0
        } else if cleanHex.count == 8 {
            r = Double((rgb >> 24) & 0xFF) / 255.0
            g = Double((rgb >> 16) & 0xFF) / 255.0
            b = Double((rgb >> 8) & 0xFF) / 255.0
            a = Double(rgb & 0xFF) / 255.0
        } else {
            return .gray
        }

        return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

struct MockDataGenerator {
    static func getMockEntries() -> [RecollectEntry] {
        let calendar = Calendar.current
        let today = Date()

        func dateFromDaysAgo(_ days: Int) -> Date {
            calendar.date(byAdding: .day, value: -days, to: today) ?? today
        }

        return [
            RecollectEntry(
                date: dateFromDaysAgo(2),
                items: [
                    EntryItem(
                        milestoneID: UUID(),
                        imageName: "placehold-1",
                        title: "Learning SwiftUI",
                        description: "Practiced SwiftUI layout, navigation, and reusable components.",
                        bgGradientStart: "#A5A827",
                        bgGradientEnd: "#DDF5FF"
                    ),
                    EntryItem(
                        milestoneID: UUID(),
                        imageName: "placehold-2",
                        title: "SwiftData Relationships",
                        description: "Learned how Roadmap and Milestone connect using SwiftData relationships.",
                        bgGradientStart: "#12C2E9",
                        bgGradientEnd: "#C471ED"
                    )
                ]
            ),
            RecollectEntry(
                date: dateFromDaysAgo(5),
                items: [
                    EntryItem(
                        milestoneID: UUID(),
                        imageName: "placehold-3",
                        title: "App Design Review",
                        description: "Improved the collection card layout and progress logic.",
                        bgGradientStart: "#FF5E62",
                        bgGradientEnd: "#FF9966"
                    )
                ]
            )
        ]
    }
}
