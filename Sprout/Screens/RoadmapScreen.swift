//
//  RoadmapScreen.swift
//  Sprout
//
//  Created by Salman Alfarisi on 25/05/26.
//

import SwiftUI
import SwiftData

struct RoadmapScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Roadmap.createdAt, order: .reverse) private var roadmaps: [Roadmap]
    
    @State private var showingAddSheet = false
    @State private var roadmapToEdit: Roadmap?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    // Header Area
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("My Roadmaps")
                                .font(.system(size: 34, weight: .bold))
                                .foregroundColor(.primary)
                            Text("Track your progress toward your dreams")
                                .font(.subheadline)
                                .foregroundColor(.primary.opacity(0.8))
                        }
                        Spacer()
                        
                        Button(action: { showingAddSheet = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 38))
                                .foregroundColor(Color(red: 76/255, green: 175/255, blue: 80/255))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    if roadmaps.isEmpty {
                        VStack {
                            Spacer()
                            ContentUnavailableView(
                                "No Roadmaps Yet",
                                systemImage: "target",
                                description: Text("Add a roadmap or goal to start tracking your journey.")
                            )
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(roadmaps) { roadmap in
                                    NavigationLink(value: roadmap) {
                                        RoadmapCardView(roadmap: roadmap, onEdit: {
                                            roadmapToEdit = roadmap
                                        })
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationDestination(for: Roadmap.self) { roadmap in
                RoadmapDetailView(roadmap: roadmap)
            }
            .sheet(isPresented: $showingAddSheet) {
                AddEditRoadmapSheet()
            }
            .sheet(item: $roadmapToEdit) { roadmap in
                AddEditRoadmapSheet(roadmap: roadmap)
            }
            .onAppear {
                seedInitialRoadmapsIfNeeded()
            }
        }
    }
    
    private func seedInitialRoadmapsIfNeeded() {
        guard roadmaps.isEmpty else { return }
        
        let r1 = Roadmap(
            title: "I want to be a photographer",
            goalDescription: "Master manual modes, lighting, composition, and build a digital portfolio.",
            colorHex: "#FF9500" // Orange
        )
        r1.milestones = [
            Milestone(title: "Understand exposure triangle (ISO, Shutter, Aperture)", isCompleted: true),
            Milestone(title: "Practice composition rules (Rule of Thirds, Leading lines)", isCompleted: true),
            Milestone(title: "Perform a portrait photoshoot with natural light", isCompleted: false),
            Milestone(title: "Publish portfolio website with 15 selected photos", isCompleted: false)
        ]
        
        let r2 = Roadmap(
            title: "I wanna learn english",
            goalDescription: "Reach C1 fluency, feel confident speaking in public, and read novels.",
            colorHex: "#007AFF" // Blue
        )
        r2.milestones = [
            Milestone(title: "Read 1 English article or news post daily", isCompleted: true),
            Milestone(title: "Watch movies in English without local subtitles", isCompleted: false),
            Milestone(title: "Attend a conversational English meetup", isCompleted: false),
            Milestone(title: "Complete 30-day vocabulary challenge", isCompleted: true)
        ]
        
        let r3 = Roadmap(
            title: "Learn SwiftUI Development",
            goalDescription: "Build and launch 3 premium native apps in the App Store.",
            colorHex: "#34C759" // Green
        )
        r3.milestones = [
            Milestone(title: "Complete basic layout tutorials", isCompleted: true),
            Milestone(title: "Implement SwiftData model persistence", isCompleted: true),
            Milestone(title: "Design custom animated tab bars", isCompleted: true),
            Milestone(title: "Submit first app to App Store Connect", isCompleted: false)
        ]
        
        modelContext.insert(r1)
        modelContext.insert(r2)
        modelContext.insert(r3)
        try? modelContext.save()
    }
}

struct RoadmapCardView: View {
    let roadmap: Roadmap
    let onEdit: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    
    var themeColor: Color {
        Color.fromHex(roadmap.colorHex)
    }
    
    var completedCount: Int {
        roadmap.milestones.filter { $0.isCompleted }.count
    }
    
    var totalCount: Int {
        roadmap.milestones.count
    }
    
    var progress: Double {
        guard totalCount > 0 else { return 0.0 }
        return Double(completedCount) / Double(totalCount)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                // Category Color Tag
                RoundedRectangle(cornerRadius: 6)
                    .fill(themeColor)
                    .frame(width: 6, height: 28)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(roadmap.title)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    if !roadmap.goalDescription.isEmpty {
                        Text(roadmap.goalDescription)
                            .font(.caption)
                            .foregroundColor(.primary.opacity(0.8))
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                // Edit & Delete Menu
                Menu {
                    Button(action: onEdit) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: deleteCard) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary.opacity(0.8).opacity(0.8))
                        .padding(8)
                }
            }
            
            // Progress Section
            VStack(spacing: 6) {
                HStack {
                    Text("\(completedCount) of \(totalCount) milestones")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary.opacity(0.8))
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(themeColor)
                }
                
                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.primary.opacity(0.8).opacity(0.15))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(themeColor)
                            .frame(width: geo.size.width * CGFloat(progress), height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemGray).opacity(0.1))
                .shadow(color: Color.primary.opacity(0.04), radius: 8, x: 0, y: 4)
        )
    }
    
    private func deleteCard() {
        withAnimation {
            modelContext.delete(roadmap)
            try? modelContext.save()
        }
    }
}

// MARK: - Roadmap Detail View
struct RoadmapDetailView: View {
    @Bindable var roadmap: Roadmap
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingEditSheet = false
    @State private var newMilestoneTitle = ""
    
    var themeColor: Color {
        Color.fromHex(roadmap.colorHex)
    }
    
    var completedCount: Int {
        roadmap.milestones.filter { $0.isCompleted }.count
    }
    
    var totalCount: Int {
        roadmap.milestones.count
    }
    
    var progress: Double {
        guard totalCount > 0 else { return 0.0 }
        return Double(completedCount) / Double(totalCount)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header card
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Roadmap Detail")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(themeColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(themeColor.opacity(0.15))
                            .cornerRadius(8)
                        
                        Spacer()
                        
                        Button("Edit Goal") {
                            showingEditSheet = true
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(themeColor)
                    }
                    
                    Text(roadmap.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if !roadmap.goalDescription.isEmpty {
                        Text(roadmap.goalDescription)
                            .font(.body)
                            .foregroundColor(.primary.opacity(0.8))
                    }
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    // Detail Progress
                    VStack(spacing: 8) {
                        HStack {
                            Text("Overall Progress")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            Spacer()
                            Text("\(completedCount)/\(totalCount) Milestones")
                                .font(.subheadline)
                                .foregroundColor(.primary.opacity(0.8))
                        }
                        
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.primary.opacity(0.8).opacity(0.12))
                                    .frame(height: 12)
                                
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(themeColor)
                                    .frame(width: geo.size.width * CGFloat(progress), height: 12)
                            }
                        }
                        .frame(height: 12)
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: Color.primary.opacity(0.04), radius: 10, x: 0, y: 6)
                )
                
                // Milestones checklist section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Milestones Checklist")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    // Quick add milestone
                    HStack {
                        TextField("Add new milestone...", text: $newMilestoneTitle)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.primary.opacity(0.8).opacity(0.08))
                            .cornerRadius(12)
                        
                        Button(action: addMilestone) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(themeColor)
                        }
                        .disabled(newMilestoneTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    
                    if roadmap.milestones.isEmpty {
                        Text("No milestones defined yet. Add one above!")
                            .font(.subheadline)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.vertical, 10)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(roadmap.milestones) { milestone in
                                MilestoneRowView(milestone: milestone, themeColor: themeColor) {
                                    toggleMilestone(milestone)
                                } onDelete: {
                                    deleteMilestone(milestone)
                                }
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            AddEditRoadmapSheet(roadmap: roadmap)
        }
    }
    
    private func addMilestone() {
        let cleanTitle = newMilestoneTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else { return }
        
        withAnimation {
            let newMilestone = Milestone(title: cleanTitle)
            newMilestone.roadmap = roadmap
            roadmap.milestones.append(newMilestone)
            newMilestoneTitle = ""
            try? modelContext.save()
        }
    }
    
    private func toggleMilestone(_ milestone: Milestone) {
        withAnimation {
            milestone.isCompleted.toggle()
            try? modelContext.save()
        }
    }
    
    private func deleteMilestone(_ milestone: Milestone) {
        withAnimation {
            roadmap.milestones.removeAll { $0.id == milestone.id }
            modelContext.delete(milestone)
            try? modelContext.save()
        }
    }
}

struct MilestoneRowView: View {
    @Bindable var milestone: Milestone
    let themeColor: Color
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            Button(action: onToggle) {
                Image(systemName: milestone.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(milestone.isCompleted ? themeColor : .primary.opacity(0.8).opacity(0.6))
            }
            
            Text(milestone.title)
                .font(.subheadline)
                .strikethrough(milestone.isCompleted)
                .foregroundColor(milestone.isCompleted ? .primary.opacity(0.8) : .primary)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.primary.opacity(0.8).opacity(0.5))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white)
                .shadow(color: Color.primary.opacity(0.02), radius: 4, x: 0, y: 2)
        )
    }
}

// MARK: - Add/Edit Roadmap Sheet
struct AddEditRoadmapSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var roadmap: Roadmap? // nil if adding
    
    @State private var title = ""
    @State private var goalDescription = ""
    @State private var colorHex = "#34C759"
    
    let colors = ["#FF3B30", "#FF9500", "#FFCC00", "#34C759", "#007AFF", "#AF52DE", "#FF2D55"]
    
    var isEditing: Bool {
        roadmap != nil
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Goal Info")) {
                    TextField("Goal Title (e.g. Speak Fluent Spanish)", text: $title)
                    TextField("Description (e.g. Complete B2 exam, read daily)", text: $goalDescription)
                }
                
                Section(header: Text("Theme Color")) {
                    HStack(spacing: 12) {
                        ForEach(colors, id: \.self) { hex in
                            Circle()
                                .fill(Color.fromHex(hex))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .stroke(Color.primary, lineWidth: colorHex == hex ? 2 : 0)
                                )
                                .onTapGesture {
                                    colorHex = hex
                                }
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle(isEditing ? "Edit Goal" : "Add Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let roadmap = roadmap {
                    title = roadmap.title
                    goalDescription = roadmap.goalDescription
                    colorHex = roadmap.colorHex
                }
            }
        }
    }
    
    private func save() {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDesc = goalDescription.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let roadmap = roadmap {
            // Update
            roadmap.title = cleanTitle
            roadmap.goalDescription = cleanDesc
            roadmap.colorHex = colorHex
        } else {
            // Create
            let newRoadmap = Roadmap(title: cleanTitle, goalDescription: cleanDesc, colorHex: colorHex)
            modelContext.insert(newRoadmap)
        }
        
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    RoadmapScreen()
        .modelContainer(for: Roadmap.self, inMemory: true)
}
