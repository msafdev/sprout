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
final class Milestone {
    var id: UUID = UUID()
    var title: String = ""
    var isCompleted: Bool = false
    var roadmap: Roadmap?
    
    init(title: String, isCompleted: Bool = false) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
    }
}
