//
//  Roadmap.swift
//  Sprout
//
//  Created by Antigravity on 25/05/26.
//

import Foundation
import SwiftData

@Model
final class Roadmap {
    var id: UUID = UUID()
    var title: String = ""
    var goalDescription: String = ""
    var colorHex: String = "#34C759" // Default to green
    var createdAt: Date = Date()
    
    @Relationship(deleteRule: .cascade, inverse: \Milestone.roadmap)
    var milestones: [Milestone] = []
    
    init(title: String, goalDescription: String = "", colorHex: String = "#34C759", createdAt: Date = Date()) {
        self.id = UUID()
        self.title = title
        self.goalDescription = goalDescription
        self.colorHex = colorHex
        self.createdAt = createdAt
        self.milestones = []
    }
}

@Model
final class Milestone: Hashable {
    var id: UUID = UUID()
    var title: String = ""
    var content: String = ""
    var isCompleted: Bool = false
    var emotionLevel: Int = 0 // 0-5, where 0 is not set
    var imageData: Data? = nil
    var createdAt: Date = Date()
    var completedAt: Date? = nil
    var roadmap: Roadmap?
    
    init(title: String, isCompleted: Bool = false, content: String = "", emotionLevel: Int = 0, createdAt: Date = Date(), completedAt: Date? = nil) {
        self.id = UUID()
        self.title = title
        self.content = content
        self.isCompleted = isCompleted
        self.emotionLevel = emotionLevel
        self.createdAt = createdAt
        self.completedAt = completedAt
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Milestone, rhs: Milestone) -> Bool {
        lhs.id == rhs.id
    }
}
