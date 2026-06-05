//
//  RoadmapScreen.swift
//  Sprout
//
//  Created by Salman Alfarisi on 25/05/26.
//

import SwiftUI
import SwiftData
import FoundationModels

// MARK: - Main Roadmap Screen Catalog Dashboard
struct RoadmapScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: \Roadmap.createdAt, order: .reverse) private var roadmaps: [Roadmap]

    @Binding var navigationPath: NavigationPath

    var totalMilestones: Int {
        roadmaps.reduce(0) { $0 + $1.milestones.count }
    }

    var sproutedMilestones: Int {
        roadmaps.reduce(0) { $0 + $1.milestones.filter { $0.isCompleted }.count }
    }

    var milestonesToSprout: Int {
        max(0, totalMilestones - sproutedMilestones)
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
                                .foregroundColor(Color(UIColor.systemBackground))
                                .frame(width: 44, height: 44)
                                .background(Color.appAccent)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    HStack(alignment: .center, spacing: 6) {
                        VStack(alignment: .leading, spacing: 8) {
                            Image("animation 5")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                            Text("Sprouted")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(spacing: 0) {
                            Text("\(sproutedMilestones)")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 40, height: 56, alignment: .center)

                        Rectangle()
                            .fill(Color.white.opacity(0.4))
                            .frame(width: 1, height: 56)

                        VStack(spacing: 0) {
                            Text("\(milestonesToSprout)")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: 40, height: 56, alignment: .center)

                        VStack(alignment: .trailing, spacing: 8) {
                            Image("animation 1")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                            Text("To Sprout")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 32)
                    .background(
                        LinearGradient(
                            colors: [Color.fromHex("#8F8E2C"), Color.fromHex("#C7C670")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
                    )
                    .cornerRadius(20)
                    .padding(.horizontal, 20)

                    if roadmaps.isEmpty {
                        VStack {
                            Spacer()
                            ContentUnavailableView(
                                "No Roadmap Yet",
                                systemImage: "target",
                                description: Text("Add a roadmap to start tracking your journey.")
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
                RoadmapDetailView(roadmap: roadmap, navigationPath: $navigationPath)
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
    let imageName: String
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(spacing: 4) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 22)
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(colorScheme == .dark ? .white : .black)
            Text(label)
                .font(.caption)
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.9) : .black.opacity(0.7))
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
                    .fill(Color.mascotAccent)
                    .frame(width: 58, height: 62)
                    .overlay(
                        VStack(spacing: 2) {
                            HStack(spacing: 6) {
                                Circle().fill(Color.white.opacity(0.9)).frame(width: 3, height: 3)
                                Circle().fill(Color.white.opacity(0.9)).frame(width: 3, height: 3)
                            }

                            Capsule()
                                .stroke(Color.white.opacity(0.9), lineWidth: 1.5)
                                .frame(width: 6, height: 2)
                        }
                        .offset(y: 4)
                    )

                Image(systemName: "leaf.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color.mascotAccent)
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
            Color.appCard

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

                Text("\(totalCount) \(totalCount == 1 ? "Milestone" : "Milestones")")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)

                HStack(spacing: 8) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(.systemGray5))
                                .frame(height: 8)

                            Capsule()
                                .fill(themeColor)
                                .frame(width: max(0, geo.size.width * CGFloat(progress)), height: 8)
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
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 4)
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
    var isGoalTitleEmpty: Bool {
        roadmap.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    @State private var showDeleteRoadmapAlert = false
    @Bindable var roadmap: Roadmap
    @Binding var navigationPath: NavigationPath

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var newMilestoneTitle = ""
    @State private var showPhotoSuggestionAlert = false
    @State private var milestonePendingCompletion: Milestone? = nil
    @State private var selectedMilestone: Milestone? = nil
    @State private var showTitleRequired = false
    @State private var aiErrorMessage = ""
    @State private var showAIErrorAlert = false
    @State private var frozenMilestoneIDs: Set<UUID> = []

    @State private var partial: NodesData.PartiallyGenerated?
    @State private var isAnalyzing = false
    @State private var note: String = ""

    @State private var showAIPromptSheet = false
    @State private var aiExtraPrompt = ""

    @State private var session = LanguageModelSession(
        instructions: Instructions {
            "You are a helpful notes assistant"
            "When using Acronyms provide definitions for clarity"
            "Never use slang language"
        }
    )
    private let aiContextMilestoneLimit = 12

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

    var sortedMilestones: [Milestone] {
        milestoneSort(for: roadmap.milestones, freezeCompletionStatus: true)
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.appBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            TextField("New Roadmap", text: $roadmap.title, axis: .vertical)
                                .lineLimit(1...)
                                .font(.title2)
                                .bold()
                                .foregroundColor(.primary)

                        }

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
                                    Image(img)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 52)
                                } else {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.primary.opacity(0.06))
                                        .frame(width: 52, height: 52)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(stageName)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(themeColor)

                                    Text(stageSubtitle)
                                        .font(.caption)
                                        .foregroundColor(.primary.opacity(0.6))
                                }

                                Spacer()

                                Text("\(Int(progress * 100))%")
                                    .font(.title3)
                                    .fontWeight(.bold)
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
                    .background(Color.appCard)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .shadow(color: Color.primary.opacity(0.04), radius: 10, x: 0, y: 6)

                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("Milestones")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)

                            Spacer()

                            Text("\(roadmap.milestones.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Button(action: { showAIPromptSheet = true }) {
                                Label("AI Add", systemImage: isAnalyzing ? "progress.indicator" : "sparkles")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(themeColor)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(themeColor.opacity(0.12))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .stroke(themeColor, lineWidth: 1.5)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            }
                            .disabled(isAnalyzing || isGoalTitleEmpty)
                        }

                        HStack(spacing: 10) {
                            TextField(
                                "Add a new milestone...",
                                text: $newMilestoneTitle
                            )
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color.appCard)
                            .cornerRadius(14)
                            .disabled(isGoalTitleEmpty)

                            Button(action: addMilestone) {
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(colorScheme == .dark ? .black : .white)
                                    .frame(width: 48, height: 48)
                                    .background(themeColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            }
                            .disabled(
                                newMilestoneTitle.trimmingCharacters(in: .whitespaces).isEmpty ||
                                isGoalTitleEmpty
                            )
                        }

                        if roadmap.milestones.isEmpty {
                            Text("No milestones yet, plant your first one above.")
                                .font(.subheadline)
                                .foregroundColor(.primary.opacity(0.5))
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(sortedMilestones) { milestone in
                                    EntryRowView(
                                        milestone: milestone,
                                        themeColor: themeColor,
                                        onToggle: { toggleMilestone(milestone) },
                                        onDelete: { deleteMilestone(milestone) },
                                        onRowTap: { selectedMilestone = milestone }
                                    )
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .scale(scale: 0.98)),
                                        removal: .opacity.combined(with: .scale(scale: 0.98))
                                    ))
                                }
                            }
                            .animation(.easeInOut(duration: 0.2), value: sortedMilestones.count)
                        }
                    }

                    Button(action: {
                        showDeleteRoadmapAlert = true
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
            .safeAreaInset(edge: .top, spacing: 0) {
                Color.clear.frame(height: 70)
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
                        .foregroundColor(colorScheme == .dark ? .black : .white)
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
        .onAppear {
            applySortedMilestonesToStore()
        }
        .onDisappear {
            if let ctx = roadmap.modelContext, !roadmap.isDeleted {
                if roadmap.title.trimmingCharacters(in: .whitespaces).isEmpty {
                    ctx.delete(roadmap)
                    try? ctx.save()
                }
            }
            applySortedMilestonesToStore()
            frozenMilestoneIDs.removeAll()
        }
        .navigationDestination(item: $selectedMilestone) { milestone in
            EntryDetailView(entry: milestone)
        }
        .alert("Delete Roadmap?", isPresented: $showDeleteRoadmapAlert) {
            Button("Cancel", role: .cancel) { }

            Button("Delete", role: .destructive) {
                modelContext.delete(roadmap)
                try? modelContext.save()
                dismiss()
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .sheet(isPresented: $showAIPromptSheet) {
            VStack(alignment: .leading, spacing: 16) {
                Text("AI Add Milestones")
                    .font(.title2)
                    .bold()

                Text("Add extra direction so the AI knows what kind of milestones to generate.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                TextEditor(text: $aiExtraPrompt)
                    .frame(height: 150)
                    .padding(8)
                    .background(Color.appCard)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                    }

                Text("AI can generate multiple milestones.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button {
                    showAIPromptSheet = false

                    Task {
                        await addMilestoneAI(extraPrompt: aiExtraPrompt)
                        aiExtraPrompt = ""
                    }
                } label: {
                    Text(isAnalyzing ? "Generating..." : "Generate Milestones")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(themeColor)
                .disabled(isAnalyzing)

                Button("Cancel") {
                    showAIPromptSheet = false
                }
                .frame(maxWidth: .infinity)

                Spacer()
            }
            .padding()
            .presentationDetents([.medium, .large])
        }
        .alert("AI generation failed", isPresented: $showAIErrorAlert) {
            Button("OK") {
                showAIErrorAlert = false
            }
        } message: {
            Text(aiErrorMessage)
        }
    }

    private func addMilestone() {
        guard !isGoalTitleEmpty else {
            withAnimation { showTitleRequired = true }
            return
        }

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

    private func addMilestoneAI(extraPrompt: String = "") async {
        guard !isGoalTitleEmpty else {
            withAnimation { showTitleRequired = true }
            return
        }

        partial = nil
        isAnalyzing = true
        defer { isAnalyzing = false }

        note = roadmap.title
        note += roadmap.goalDescription.isEmpty ? "" : " and the goal description: \(roadmap.goalDescription)."
        let contextMilestones = latestMilestonesForAIContext()
        if !contextMilestones.isEmpty {
            note += " the following recent actionable items are currently in this roadmap, don't repeat them and analyze them so you can guess what the next few new nodes should be: " + contextMilestones.map(\.title).joined(separator: ", ") + "."
        }

        let cleanExtraPrompt = extraPrompt.trimmingCharacters(in: .whitespacesAndNewlines)

        if !cleanExtraPrompt.isEmpty {
            note += " Extra user direction: \(cleanExtraPrompt)."
        }

        do {
            print(note)

            let stream = session.streamResponse(generating: NodesData.self) {
                "Make actionable items from the following prompt: \(note)"
            }

            for try await snapshot in stream {
                partial = snapshot.content
            }
        } catch {
            showAIError(for: error)
            return
        }

        guard let items = partial?.actionItems else {
            showAIError(for: NSError(domain: "Roadmap.AI", code: 0, userInfo: [NSLocalizedDescriptionKey: "No milestones were returned by the AI."]))
            return
        }

        let parsedItems = items.compactMap { item in
            item.trimmingCharacters(in: .whitespacesAndNewlines)
        }.filter { !$0.isEmpty }
        if parsedItems.isEmpty {
            showAIError(for: NSError(domain: "Roadmap.AI", code: 1, userInfo: [NSLocalizedDescriptionKey: "The AI returned no valid milestone text."]))
            return
        }

        for item in parsedItems {
            let newMilestone = Milestone(title: item)
            newMilestone.roadmap = roadmap
            roadmap.milestones.append(newMilestone)
        }

        try? modelContext.save()
    }

    @MainActor
    private func showAIError(for error: Error) {
        let message = error.localizedDescription.lowercased()
        if message.contains("unsafe") || message.contains("safety") {
            aiErrorMessage = "The AI blocked this request for safety reasons. Please don't put unsafe words and rephrase your roadmap title / description / milestones / prompt."
        } else {
            aiErrorMessage = "Couldn’t complete milestone generation. \(error.localizedDescription)"
        }
        showAIErrorAlert = true
    }

    private func toggleMilestone(_ milestone: Milestone) {
        withAnimation(.easeInOut(duration: 0.2)) {
            let wasCompleted = milestone.isCompleted

            if milestone.isCompleted {
                milestone.isCompleted = false
                milestone.completedAt = nil
                frozenMilestoneIDs.remove(milestone.id)
            }
            else {
                milestone.isCompleted = true
                milestone.completedAt = Date()
                if !wasCompleted {
                    frozenMilestoneIDs.insert(milestone.id)
                }
            }

            try? modelContext.save()
        }
    }

    private func milestoneSort(for milestones: [Milestone], freezeCompletionStatus: Bool) -> [Milestone] {
        milestones.sorted {
            let leftPriority = sortPriority(for: $0, freezeCompletionStatus: freezeCompletionStatus)
            let rightPriority = sortPriority(for: $1, freezeCompletionStatus: freezeCompletionStatus)

            if leftPriority != rightPriority {
                return leftPriority < rightPriority
            }

            if $0.createdAt != $1.createdAt {
                return $0.createdAt < $1.createdAt
            }

            return $0.id.uuidString < $1.id.uuidString
        }
    }

    private func sortPriority(for milestone: Milestone, freezeCompletionStatus: Bool) -> Int {
        if freezeCompletionStatus && frozenMilestoneIDs.contains(milestone.id) {
            return 0
        }

        return milestone.isCompleted ? 1 : 0
    }

    private func latestMilestonesForAIContext() -> [Milestone] {
        roadmap.milestones
            .sorted { $0.createdAt < $1.createdAt }
            .suffix(aiContextMilestoneLimit)
            .map { $0 }
    }

    private func applySortedMilestonesToStore() {
        roadmap.milestones = milestoneSort(for: roadmap.milestones, freezeCompletionStatus: false)
        try? modelContext.save()
    }

    private func deleteMilestone(_ milestone: Milestone) {
        withAnimation(.easeInOut(duration: 0.2)) {
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
            Image(systemName: milestone.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 24))
                .foregroundColor(milestone.isCompleted ? themeColor : .primary.opacity(0.35))
                .onTapGesture {
                    onToggle()
                }

            // Central Tap Segment (Navigates cleanly to Detail Cards)
            VStack(alignment: .leading, spacing: 3) {
                Text(milestone.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .strikethrough(milestone.isCompleted)
                    .foregroundColor(milestone.isCompleted ? .primary.opacity(0.55) : .primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                onRowTap()
            }

            if milestone.emotionLevel > 0 {
                Image(emotionEmoji(for: milestone.emotionLevel))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 22, height: 22)
            }

            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.primary.opacity(0.4))
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 24)
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .scale(scale: 0.98)),
            removal: .opacity.combined(with: .scale(scale: 0.98))
        ))
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.appCard)
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
