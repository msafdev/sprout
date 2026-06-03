//
//  RoadmapScreen.swift
//  Sprout
//
//  Created by Salman Alfarisi on 25/05/26.
//

import SwiftUI
import SwiftData

// MARK: - Main Roadmap Screen Catalog Dashboard
struct RoadmapScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Roadmap.createdAt, order: .reverse) private var roadmaps: [Roadmap]

    @Binding var navigationPath: NavigationPath

    var totalEntries: Int {
        roadmaps.reduce(0) { $0 + $1.milestones.count }
    }

    var completedEntries: Int {
        roadmaps.reduce(0) { $0 + $1.milestones.filter { $0.isCompleted }.count }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                AppGradientBackground()

                VStack(alignment: .leading, spacing: 20) {
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

                        Button(action: {
                            let roadmap = Roadmap(title: "", goalDescription: "", colorHex: "#9F9E32")
                            modelContext.insert(roadmap)
                            try? modelContext.save()
                            navigationPath.append(roadmap)
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.appAccent)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    HStack(spacing: 16) {
                        MascotStatView()
                            .frame(width: 82, height: 82)

                        HStack(spacing: 0) {
                            StatItemView(label: "Collection", value: "\(roadmaps.count)")
                            StatItemView(label: "Entries", value: "\(totalEntries)")
                            StatItemView(label: "Sprouted", value: "\(completedEntries)")
                        }
                    }
                    .padding(16)
                    .background(Color.appAccent)
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
                            let columns = [GridItem(.flexible()), GridItem(.flexible())]
                            LazyVGrid(columns: columns, spacing: 20) {
                                ForEach(roadmaps) { roadmap in
                                    NavigationLink(value: roadmap) {
                                        RoadmapCardView(roadmap: roadmap)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                            .padding(.top, 4)
                        }
                    }
                }
            }
            .navigationDestination(for: Roadmap.self) { roadmap in
                RoadmapDetailView(roadmap: roadmap)
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
            colorHex: "#9F9E32"
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

// MARK: - Stat Views
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
                    .fill(Color.appAccent)
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
                    .foregroundColor(Color.appAccent)
                    .rotationEffect(.degrees(-35))
                    .offset(x: 5, y: -20)
            }
        }
    }
}

// MARK: - Roadmap Grid Thumbnail Dashboard Card Component
struct RoadmapCardView: View {
    let roadmap: Roadmap

    @Environment(\.modelContext) private var modelContext

    var themeColor: Color { Color.fromHex(roadmap.colorHex) }
    var completedCount: Int { roadmap.milestones.filter { $0.isCompleted }.count }
    var totalCount: Int { roadmap.milestones.count }
    
    var progress: Double {
        guard totalCount > 0 else { return 0.0 }
        return Double(completedCount) / Double(totalCount)
    }
    
    var sproutImage: String? {
        guard totalCount > 0 else { return nil }
        if progress == 0 { return "animation 1" }
        if progress <= 0.25 { return "animation 2" }
        if progress <= 0.50 { return "animation 3" }
        if progress <= 0.75 { return "animation 4" }
        return "animation 5"
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white

            if let img = sproutImage {
                Image(img)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 120)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(roadmap.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(themeColor)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                Text("\(totalCount) \(totalCount == 1 ? "Entry" : "Entries")")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)

                HStack(spacing: 8) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color(.systemGray5)).frame(height: 8)
                            Capsule().fill(themeColor).frame(width: max(0, geo.size.width * CGFloat(progress)), height: 8)
                        }
                    }
                    .frame(height: 8)

                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(themeColor)
                        .fixedSize()
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
        .contextMenu {
            Button(role: .destructive) {
                modelContext.delete(roadmap)
                try? modelContext.save()
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

// MARK: - Detailed Inside Workspace View
struct RoadmapDetailView: View {
    @Bindable var roadmap: Roadmap
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var newMilestoneTitle = ""
    @State private var showImageRequiredAlert = false
    @State private var selectedMilestone: Milestone? = nil
    @State private var showTitleRequired = false

    var themeColor: Color { Color.fromHex(roadmap.colorHex) }
    var completedCount: Int { roadmap.milestones.filter { $0.isCompleted }.count }
    var totalCount: Int { roadmap.milestones.count }
    
    var progress: Double {
        guard totalCount > 0 else { return 0.0 }
        return Double(completedCount) / Double(totalCount)
    }
    
    var sproutImage: String? {
        guard totalCount > 0 else { return nil }
        if progress == 0 { return "animation 1" }
        if progress <= 0.25 { return "animation 2" }
        if progress <= 0.50 { return "animation 3" }
        if progress <= 0.75 { return "animation 4" }
        return "animation 5"
    }
    
    var stageName: String {
        if totalCount == 0 { return "Nothing Planted Yet" }
        if progress == 0 { return "Freshly Planted" }
        if progress <= 0.25 { return "Sprouting Up" }
        if progress <= 0.50 { return "Growing Strong" }
        if progress <= 0.75 { return "Almost There" }
        return "Fully Sprouted!"
    }
    
    var stageSubtitle: String {
        if totalCount == 0 { return "Add a milestone to begin your journey" }
        if progress == 0 { return "Every journey starts with a single seed." }
        if completedCount == totalCount { return "You've completed all milestones!" }
        return "\(totalCount - completedCount) more to grow"
    }

    var body: some View {
        ZStack(alignment: .top) {
            // 1. Set the global background color for the entire view
            Color.appBackground.ignoresSafeArea()

            // 2. Main Scrollable Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Spacer pushes content below the fixed header
                    Spacer().frame(height: 90)

                    // Header Goal Info Workspace Card
                    VStack(alignment: .leading, spacing: 14) {
                        TextField("New goal", text: $roadmap.title, axis: .vertical)
                            .lineLimit(1...)
                            .font(.title2).bold()
                            .foregroundColor(.primary)

                        if showTitleRequired && roadmap.title.trimmingCharacters(in: .whitespaces).isEmpty {
                            Text("Please enter a title before saving.")
                                .font(.caption)
                                .foregroundColor(.red)
                                .transition(.opacity)
                        }

                        TextField("Describe what growing here looks like.", text: $roadmap.goalDescription, axis: .vertical)
                            .font(.body)
                            .foregroundColor(.primary.opacity(0.8))
                            .lineLimit(2...4)

                        Divider().padding(.vertical, 2)

                        VStack(spacing: 10) {
                            HStack(spacing: 12) {
                                if let img = sproutImage {
                                    Image(img).resizable().scaledToFit().frame(height: 52)
                                } else {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.primary.opacity(0.06))
                                        .frame(width: 52, height: 52)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(stageName)
                                        .font(.subheadline).fontWeight(.bold)
                                        .foregroundColor(themeColor)
                                    Text(stageSubtitle)
                                        .font(.caption)
                                        .foregroundColor(.primary.opacity(0.6))
                                }
                                Spacer()
                                Text("\(Int(progress * 100))%")
                                    .font(.title3).fontWeight(.bold)
                                    .foregroundColor(themeColor)
                            }

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.primary.opacity(0.10))
                                        .frame(height: 10)
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(themeColor)
                                        .frame(width: max(0, geo.size.width * CGFloat(progress)), height: 10)
                                }
                            }
                            .frame(height: 10)
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: Color.primary.opacity(0.04), radius: 10, x: 0, y: 6)

                    // Milestones Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Milestones")
                            .font(.title3).fontWeight(.bold)
                            .foregroundColor(.primary)

                        HStack(spacing: 10) {
                            TextField("Add a new milestone...", text: $newMilestoneTitle)
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color.white)
                                .cornerRadius(14)

                            Button(action: addMilestone) {
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 48, height: 48)
                                    .background(themeColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            .disabled(newMilestoneTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                        }

                        if roadmap.milestones.isEmpty {
                            Text("No milestones yet, plant your first one above.")
                                .font(.subheadline)
                                .foregroundColor(.primary.opacity(0.5))
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(roadmap.milestones) { milestone in
                                    EntryRowView(
                                        milestone: milestone,
                                        themeColor: themeColor,
                                        onToggle: { toggleMilestone(milestone) },
                                        onDelete: { deleteMilestone(milestone) },
                                        onRowTap: { selectedMilestone = milestone }
                                    )
                                }
                            }
                        }
                    }

                    Button(action: {
                        modelContext.delete(roadmap)
                        try? modelContext.save()
                        dismiss()
                    }) {
                        Text("Delete Roadmap")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    Spacer().frame(height: 40)
                }
                .padding(20)
            }

            // 3. Fixed Header (Kept at top of ZStack)
            HStack {
                Button(action: {
                    if roadmap.title.trimmingCharacters(in: .whitespaces).isEmpty {
                        modelContext.delete(roadmap)
                        try? modelContext.save()
                    }
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(Color.appBackground.opacity(0.8))
                        .clipShape(Circle())
                }
 
                Spacer()
 
                Button(action: {
                    if roadmap.title.trimmingCharacters(in: .whitespaces).isEmpty {
                        withAnimation { showTitleRequired = true }
                    } else {
                        try? modelContext.save()
                        dismiss()
                    }
                }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.appAccent)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .background(Color.appBackground.ignoresSafeArea(edges: .top))
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationDestination(item: $selectedMilestone) { milestone in
            EntryDetailView(entry: milestone)
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

// MARK: - Individual Row Component (Avoids Gesture Hierarchy Interferences)
struct EntryRowView: View {
    @Bindable var milestone: Milestone
    let themeColor: Color
    let onToggle: () -> Void
    let onDelete: () -> Void
    let onRowTap: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Checkbox Control Handle
            Image(systemName: milestone.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 24))
                .foregroundColor(milestone.isCompleted ? themeColor : .primary.opacity(0.35))
                .onTapGesture {
                    onToggle()
                }

            // Central Tap Segment (Navigates cleanly to Detail Cards)
            VStack(alignment: .leading, spacing: 3) {
                Text(milestone.title)
                    .font(.subheadline).fontWeight(.semibold)
                    .strikethrough(milestone.isCompleted)
                    .foregroundColor(milestone.isCompleted ? .primary.opacity(0.55) : .primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                if !milestone.isCompleted && milestone.imageData == nil {
                    Text("Photo required to finish")
                        .font(.caption2)
                        .foregroundColor(.red)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                onRowTap()
            }

            if milestone.emotionLevel > 0 {
                Image(emotionEmoji(for: milestone.emotionLevel)) // Uses the function to get the asset name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22) // Matches your previous size
            }

            // Destructive Delete Controls Action Item
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.primary.opacity(0.4))
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white)
        )
    }

    private func emotionEmoji(for level: Int) -> String {
        let moodAssets = ["s_angry", "s_confused", "s_sad", "s_flat", "s_happy"]
        let cleanIndex = max(0, min(level - 1, moodAssets.count - 1))
        return moodAssets[cleanIndex]
    }
}

// MARK: - Local Canvas Previews Environment Configuration Setup
#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Roadmap.self, Milestone.self, configurations: config)
    
    return RoadmapScreen(navigationPath: .constant(NavigationPath()))
        .modelContainer(container)
}
