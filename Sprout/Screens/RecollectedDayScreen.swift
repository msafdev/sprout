//
//  RecollectedDayScreen.swift
//  Sprout
//
//  Created by Gusti Sandyaga Putra Wardhana on 03/06/26.
//

import SwiftUI
import SwiftData

struct RecollectDetailView: View {
    let allMilestones: [Milestone]
    @State private var currentDate: Date
    @State private var selectedRoadmapID: PersistentIdentifier?
    @State private var selectedMilestoneIndex = 0
    
    private let calendar = Calendar.current
    
    init(date: Date, allMilestones: [Milestone]) {
        self.allMilestones = allMilestones
        self._currentDate = State(initialValue: date)
    }

    // MARK: - Logic Helpers
    private var datesWithMilestones: [Date] {
        let uniqueDays = Set(allMilestones.compactMap { $0.completedAt }.map { calendar.startOfDay(for: $0) })
        return uniqueDays.sorted()
    }

    private var currentDayMilestones: [Milestone] {
        allMilestones.filter { milestone in
            guard let completedAt = milestone.completedAt else { return false }
            return calendar.isDate(completedAt, inSameDayAs: currentDate)
        }
    }
    
    private var roadmapsForDay: [Roadmap] {
        let uniqueRoadmaps = Set(currentDayMilestones.compactMap { $0.roadmap })
        return Array(uniqueRoadmaps).sorted { ($0.title) < ($1.title) }
    }
    
    private var milestonesForSelectedRoadmap: [Milestone] {
        guard let roadmapID = selectedRoadmapID else { return [] }
        return currentDayMilestones.filter { $0.roadmap?.persistentModelID == roadmapID }
    }

    var body: some View {
        ZStack{
            AppGradientBackground()
            ScrollView {
                VStack(spacing: 20) {
                    // Roadmap Horizontal Scroll
                    if !roadmapsForDay.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(roadmapsForDay, id: \.persistentModelID) { roadmap in
                                    Button(action: {
                                        selectedRoadmapID = roadmap.persistentModelID
                                    }) {
                                        Text(roadmap.title)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 16)
                                            .background(selectedRoadmapID == roadmap.persistentModelID ? Color.appAccent : Color.gray.opacity(0.1))
                                            .foregroundColor(selectedRoadmapID == roadmap.persistentModelID ? Color(UIColor.systemBackground) : .primary)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        .onChange(of: selectedRoadmapID) { selectedMilestoneIndex = 0 }
                    }

                    // Main Slider
                    if !milestonesForSelectedRoadmap.isEmpty {
                        TabView(selection: $selectedMilestoneIndex) {
                            ForEach(0..<milestonesForSelectedRoadmap.count, id: \.self) { i in
                                MilestonePhotoView(milestone: milestonesForSelectedRoadmap[i])
                                    .tag(i)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .always))
                        .frame(height: 400)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .padding(.horizontal, 24)
                    }

                    // Date Navigation
                    DateNavigationRow(currentDate: $currentDate, dates: datesWithMilestones)
                        .padding(.top, 10)
                }
                .padding(.top, 20)
            }

        }
        .background(Color.appBackground)
        .navigationTitle(PresentationHelpers.formattedDateOrdinal(currentDate))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if selectedRoadmapID == nil { selectedRoadmapID = roadmapsForDay.first?.persistentModelID }
        }
    }
}

struct MilestonePhotoView: View {
    let milestone: Milestone
    
    private func getEmotionAssetName(for level: Int) -> String {
        let moodAssets = ["s_angry", "s_confused", "s_sad", "s_flat", "s_happy"]
        return moodAssets[max(0, min(level - 1, moodAssets.count - 1))]
    }
    
    var body: some View {
        // 1. The base image view with a fixed frame constraint
        Group {
            if let data = milestone.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                // UPDATED: Placeholder image instead of a gray color block
                Image("placeholder") // <-- Use the same asset name here
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .frame(width: 340, height: 400) // Force the image size to match the TabView frame
        .clipped()
        .overlay(
            // 2. The Text/Emotion content pinned to the bottom
            VStack {
                Spacer()
                
                // Gradient layer within the overlay
                LinearGradient(colors: [.black.opacity(0.6), .clear], startPoint: .bottom, endPoint: .top)
                    .frame(height: 120)
                    .overlay(
                        HStack(alignment: .bottom, spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(milestone.title)
                                    .font(.title3).bold().foregroundColor(.white)
                                Text(milestone.content)
                                    .font(.footnote).foregroundColor(.white.opacity(0.85))
                            }
                            
                            Spacer()
                            
                            Image(getEmotionAssetName(for: milestone.emotionLevel))
                                .resizable()
                                .scaledToFit()
                                .frame(width: 42, height: 42)
                        }
                        .padding(24)
                    )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

struct DateNavigationRow: View {
    @Binding var currentDate: Date
    let dates: [Date]
    
    var body: some View {
        let idx = dates.firstIndex(where: { Calendar.current.isDate($0, inSameDayAs: currentDate) }) ?? 0
        
        HStack(spacing: 40) {
            // Only show "Previous days" if there is a date before the current one
            if idx > 0 {
                Button(action: { currentDate = dates[idx - 1] }) {
                    Label("Previous days", systemImage: "arrow.left")
                }
            }
            
            Spacer() // This pushes the buttons apart if only one is visible
            
            // Only show "Next days" if there is a date after the current one
            if idx < dates.count - 1 {
                Button(action: { currentDate = dates[idx + 1] }) {
                    Label("Next days", systemImage: "arrow.right")
                }
            }
        }
        .font(.subheadline)
        .foregroundColor(.secondary)
        .padding(.horizontal, 24) // Added padding to keep them off the edges
    }
}

#Preview {
    // 1. Create a temporary in-memory container
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Milestone.self, Roadmap.self, configurations: config)
    
    // 2. Create some sample data
    let roadmap = Roadmap(title: "Photography Basics")
    let milestone = Milestone(
        title: "Golden Hour Practice",
        content: "Trying to catch the soft light.",
        emotionLevel: 5,
        completedAt: Date()
    )
    milestone.roadmap = roadmap
    
    // 3. Add to context
    container.mainContext.insert(roadmap)
    container.mainContext.insert(milestone)
    
    // 4. Return the view
    return NavigationStack {
        RecollectDetailView(date: Date(), allMilestones: [milestone])
            .modelContainer(container)
    }
}
