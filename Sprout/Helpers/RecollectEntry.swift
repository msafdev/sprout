//
//  RecollectEntry.swift
//  Sprout
//
//  Created by Salman Alfarisi on 25/05/26.
//

import SwiftUI

struct RecollectEntry: Identifiable, Codable {
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
}

// Helper to convert Hex to Color
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

struct EntryItem: Identifiable, Codable {
    var id: UUID = UUID()
    var imageName: String
    var title: String
    var description: String
    var bgGradientStart: String
    var bgGradientEnd: String
}

// Generate Mock Data
struct MockDataGenerator {
    static func getMockEntries() -> [RecollectEntry] {
        let calendar = Calendar.current
        let today = Date()
        
        func dateFromDaysAgo(_ days: Int) -> Date {
            calendar.date(byAdding: .day, value: -days, to: today) ?? today
        }
        
        return [
            // Current month entries (May 2026)
            RecollectEntry(
                date: dateFromDaysAgo(2), // 2 days ago
                items: [
                    EntryItem(
                        imageName: "placehold-1",
                        title: "Learning Swift UI",
                        description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis rutrum porta condimentum. Suspendisse potenti.",
                        bgGradientStart: "#FF5E62",
                        bgGradientEnd: "#FF9966"
                    ),
                    EntryItem(
                        imageName: "placehold-2",
                        title: "Morning Coffee Brew",
                        description: "Tried a new Ethiopian light roast coffee today. Floral notes with high acidity.",
                        bgGradientStart: "#8A2387",
                        bgGradientEnd: "#E94057"
                    ),
                    EntryItem(
                        imageName: "placehold-3",
                        title: "Desk Setup Progress",
                        description: "Organized the cables and set up the new mechanical keyboard.",
                        bgGradientStart: "#12C2E9",
                        bgGradientEnd: "#C471ED"
                    )
                ]
            ),
            RecollectEntry(
                date: dateFromDaysAgo(5),
                items: [
                    EntryItem(
                        imageName: "placehold-2",
                        title: "Evening Stroll",
                        description: "Walked around the local park. The weather was perfect and the sunset was beautiful.",
                        bgGradientStart: "#8A2387",
                        bgGradientEnd: "#E94057"
                    )
                ]
            ),
            RecollectEntry(
                date: dateFromDaysAgo(10),
                items: [
                    EntryItem(
                        imageName: "placehold-3",
                        title: "Coding Session",
                        description: "Deep dive into SwiftData relationships and custom animations.",
                        bgGradientStart: "#12C2E9",
                        bgGradientEnd: "#C471ED"
                    ),
                    EntryItem(
                        imageName: "placehold-1",
                        title: "Reading Time",
                        description: "Read another chapter of 'Atomic Habits'. Focus on visual cues.",
                        bgGradientStart: "#FF5E62",
                        bgGradientEnd: "#FF9966"
                    )
                ]
            ),
            
            // Last month entries (April 2026)
            RecollectEntry(
                date: dateFromDaysAgo(25),
                items: [
                    EntryItem(
                        imageName: "placehold-1",
                        title: "Healthy Lunch Prep",
                        description: "Made an avocado chicken salad with homemade lime dressing.",
                        bgGradientStart: "#11998E",
                        bgGradientEnd: "#38EF7D"
                    )
                ]
            ),
            RecollectEntry(
                date: dateFromDaysAgo(32),
                items: [
                    EntryItem(
                        imageName: "placehold-2",
                        title: "Guitar Practice",
                        description: "Learned the chord transitions for a new classical song.",
                        bgGradientStart: "#FC466B",
                        bgGradientEnd: "#3F5EFB"
                    ),
                    EntryItem(
                        imageName: "placehold-3",
                        title: "Drawing Session",
                        description: "Sketching quick poses. Trying to improve gesture drawing speed.",
                        bgGradientStart: "#00F2FE",
                        bgGradientEnd: "#4FACFE"
                    ),
                    EntryItem(
                        imageName: "placehold-1",
                        title: "Running Routine",
                        description: "Ran 5km. Better pace than last week. Feeling energized.",
                        bgGradientStart: "#FF5E62",
                        bgGradientEnd: "#FF9966"
                    )
                ]
            ),
            RecollectEntry(
                date: dateFromDaysAgo(40),
                items: [
                    EntryItem(
                        imageName: "placehold-3",
                        title: "New Plant Setup",
                        description: "Repotted the monstera deliciosa. It's growing super fast!",
                        bgGradientStart: "#00F2FE",
                        bgGradientEnd: "#4FACFE"
                    )
                ]
            ),
            
            // 2 Months ago entries (March 2026)
            RecollectEntry(
                date: dateFromDaysAgo(60),
                items: [
                    EntryItem(
                        imageName: "placehold-1",
                        title: "Bicycle Ride",
                        description: "Rode along the river trail. Caught a glimpse of some ducks.",
                        bgGradientStart: "#FF0844",
                        bgGradientEnd: "#FFB199"
                    )
                ]
            ),
            RecollectEntry(
                date: dateFromDaysAgo(72),
                items: [
                    EntryItem(
                        imageName: "placehold-2",
                        title: "Watercolors Practice",
                        description: "Painting a landscape watercolor scene. Blending skies.",
                        bgGradientStart: "#F12711",
                        bgGradientEnd: "#F5AF19"
                    ),
                    EntryItem(
                        imageName: "placehold-3",
                        title: "Cooking Experiment",
                        description: "Tried baking sourdough bread. Crust was perfect but inside was a bit dense.",
                        bgGradientStart: "#9AD0C2",
                        bgGradientEnd: "#2D9596"
                    )
                ]
            ),
            RecollectEntry(
                date: dateFromDaysAgo(80),
                items: [
                    EntryItem(
                        imageName: "placehold-3",
                        title: "Spring Cleaning",
                        description: "Decluttered the closet and organized bookshelves.",
                        bgGradientStart: "#9AD0C2",
                        bgGradientEnd: "#2D9596"
                    )
                ]
            )
        ]
    }
}
