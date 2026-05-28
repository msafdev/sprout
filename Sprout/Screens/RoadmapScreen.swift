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
    
    var totalEntries: Int {
        roadmaps.reduce(0) { $0 + $1.milestones.count }
    }
    
    var completedEntries: Int {
        roadmaps.reduce(0) { $0 + $1.milestones.filter { $0.isCompleted }.count }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 20) {
                    // Header Area
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Roadmap")
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
                                .foregroundColor(Color(red: 150/255, green: 180/255, blue: 80/255))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Statistics Bar
                    HStack(spacing: 16) {
                        MascotStatView()
                            .frame(width: 82, height: 82)
                        
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                StatItemView(label: "Collection", value: "\(roadmaps.count)")
                                StatItemView(label: "Entries", value: "\(totalEntries)")
                                StatItemView(label: "Sprouted", value: "\(completedEntries)")
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(red: 150/255, green: 180/255, blue: 80/255))
                    .cornerRadius(24)
                    .padding(.horizontal, 20)
                    
                    if roadmaps.isEmpty {
                        VStack {
                            Spacer()
                            ContentUnavailableView(
                                "No Roadmap Yet",
                                systemImage: "target",
                                description: Text("Add a collection to start tracking your journey.")
                            )
                            Spacer()
                        }
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                // Grid layout
                                let columns = [GridItem(.flexible()), GridItem(.flexible())]
                                LazyVGrid(columns: columns, spacing: 20) {
                                    ForEach(roadmaps) { roadmap in
                                        NavigationLink(value: roadmap) {
                                            RoadmapCardView(roadmap: roadmap, onEdit: {
                                                roadmapToEdit = roadmap
                                            })
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
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
        
        let roadmap = Roadmap(
            title: "Become a Confident Visual Storyteller",
            goalDescription: "Capture everyday scenes with intention, review results, and refine every shot.",
            colorHex: "#34C759"
        )
        roadmap.milestones = [
            Milestone(title: "Assess current camera skills and setup"),
            Milestone(title: "Practice three photo compositions with available light"),
            Milestone(title: "Review selected shots and identify improvement areas")
        ]
        
        modelContext.insert(roadmap)
        try? modelContext.save()
    }
}

struct StatItemView: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }
}

struct MascotStatView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22)
                .fill(Color.white.opacity(0.2))
            
            ZStack(alignment: .topTrailing) {
                Ellipse()
                    .fill(Color(red: 139/255, green: 165/255, blue: 67/255))
                    .frame(width: 58, height: 62)
                    .overlay(
                        VStack(spacing: 2) {
                            HStack(spacing: 6) {
                                Circle().fill(Color.black.opacity(0.8)).frame(width: 3, height: 3)
                                Circle().fill(Color.black.opacity(0.8)).frame(width: 3, height: 3)
                            }
                            Capsule().stroke(Color.black.opacity(0.8), lineWidth: 1.5).frame(width: 6, height: 2)
                        }
                        .offset(y: 4)
                    )
                
                Image(systemName: "leaf.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(red: 139/255, green: 165/255, blue: 67/255))
                    .rotationEffect(.degrees(-35))
                    .offset(x: 5, y: -20)
            }
        }
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
        VStack(alignment: .leading, spacing: 12) {
            // Color tag
            HStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(themeColor)
                    .frame(width: 4, height: 16)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(roadmap.title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text("\(totalCount) Entries")
                        .font(.caption)
                        .foregroundColor(.primary.opacity(0.7))
                }
                
                Spacer()
                
                Menu {
                    Button(action: onEdit) {
                        Label("Edit", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: deleteCard) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary.opacity(0.6))
                }
            }
            
            // Progress
            VStack(spacing: 6) {
                HStack {
                    Text("\(completedCount) of \(totalCount)")
                        .font(.caption2)
                        .foregroundColor(.primary.opacity(0.7))
                    
                    Spacer()
                    
                    Text("\(Int(progress * 100))%")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(themeColor)
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.primary.opacity(0.1))
                        
                        RoundedRectangle(cornerRadius: 3)
                            .fill(themeColor)
                            .frame(width: geo.size.width * CGFloat(progress))
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(16)
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
    @State private var showImageRequiredAlert = false
    
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
                
                // Entries section
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
                        Text("No entries defined yet. Add one above!")
                            .font(.subheadline)
                            .foregroundColor(.primary.opacity(0.8))
                            .padding(.vertical, 10)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(roadmap.milestones) { milestone in
                                NavigationLink(value: milestone) {
                                    EntryRowView(milestone: milestone, themeColor: themeColor) {
                                        toggleMilestone(milestone)
                                    } onDelete: {
                                        deleteMilestone(milestone)
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Color.white)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Milestone.self) { milestone in
            EntryDetailView(entry: milestone)
        }
        .sheet(isPresented: $showingEditSheet) {
            AddEditRoadmapSheet(roadmap: roadmap)
        }
        .alert("Photo required", isPresented: $showImageRequiredAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Add a photo in the entry detail before marking this lesson as finished.")
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
            if milestone.isCompleted {
                milestone.isCompleted = false
                milestone.completedAt = nil
            } else if milestone.imageData != nil {
                milestone.isCompleted = true
                milestone.completedAt = Date()
            } else {
                showImageRequiredAlert = true
                return
            }
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

struct EntryRowView: View {
    @Bindable var milestone: Milestone
    let themeColor: Color
    let onToggle: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: milestone.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(milestone.isCompleted ? themeColor : .primary.opacity(0.8).opacity(0.6))
            }
            .disabled(!milestone.isCompleted && milestone.imageData == nil)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(milestone.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .strikethrough(milestone.isCompleted)
                    .foregroundColor(milestone.isCompleted ? .primary.opacity(0.8) : .primary)
                    .multilineTextAlignment(.leading)
                
                if !milestone.content.isEmpty {
                    Text(milestone.content)
                        .font(.caption)
                        .foregroundColor(.primary.opacity(0.6))
                        .lineLimit(1)
                }
                if !milestone.isCompleted && milestone.imageData == nil {
                    Text("Photo required to finish")
                        .font(.caption2)
                        .foregroundColor(.red)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Emotion level display
            if milestone.emotionLevel > 0 {
                Text(emotionEmoji(for: milestone.emotionLevel))
                    .font(.system(size: 20))
            }
            
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
                .fill(Color(.systemGray6))
        )
    }
    
    private func emotionEmoji(for level: Int) -> String {
        let emojis = ["😢", "😕", "😐", "🙂", "😄"]
        return emojis[level - 1]
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
        .modelContainer(for: [Roadmap.self, Milestone.self], inMemory: true)
}
