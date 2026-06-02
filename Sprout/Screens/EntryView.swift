//
//  EntryView.swift
//  Sprout
//

import SwiftUI
import SwiftData

struct EntryView: View {
    let capturedImage: UIImage
    var onSaveComplete: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // --- Navigation ---
    @State private var navigationPath = NavigationPath()
    
    // --- SwiftData Query ---
    @Query(sort: \Roadmap.createdAt, order: .reverse) private var existingRoadmaps: [Roadmap]
    
    // --- Dynamic Form Input States ---
    // 1. Roadmap Data Fields
    @State private var collectionText: String = ""       // Roadmap Title
    @State private var goalDescriptionText: String = ""  // Roadmap Goal Description (New Roadmaps Only)
    
    // 2. Milestone Data Fields
    @State private var milestoneTitleText: String = ""   // Milestone Title
    @State private var entriesText: String = ""          // Milestone Content Explanation
    @State private var selectedMood: Int = 3             // Milestone Emotion Level (Default: 3)
    
    // --- Selection and UI Focus Tracking ---
    @State private var selectedRoadmap: Roadmap? = nil
    @State private var selectedMilestone: Milestone? = nil // Tracks if updating an existing incomplete milestone
    
    @State private var isRoadmapDropdownFocused: Bool = false
    @State private var isMilestoneDropdownFocused: Bool = false
    @FocusState private var isExplanationFocused: Bool
    
    // --- Filtering Logic ---
    var filteredRoadmaps: [Roadmap] {
        if collectionText.isEmpty {
            return existingRoadmaps
        } else {
            return existingRoadmaps.filter { $0.title.localizedCaseInsensitiveContains(collectionText) }
        }
    }
    
    // --- Filtering Logic Fix ---
    var filteredMilestones: [Milestone] {
        guard let roadmap = selectedRoadmap else { return [] }
        // Filter out completed items using the model's boolean flag directly
        let incompleteMilestones = roadmap.milestones.filter { !$0.isCompleted }
        
        if milestoneTitleText.isEmpty {
            return incompleteMilestones.sorted(by: { ($0.createdAt) < ($1.createdAt) })
        } else {
            return incompleteMilestones
                .filter { $0.title.localizedCaseInsensitiveContains(milestoneTitleText) }
                .sorted(by: { ($0.createdAt) < ($1.createdAt) })
        }
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .top) {
                Color(.systemGroupedBackground).ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    Spacer().frame(height: 60) // spacer to push content below the header
                    
                    // --- 1. CAPTURED MEDIA WORKSPACE PREVIEW ---
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 10) {
                            Text("Captured Snapshot")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                            Spacer()
                            Text("Attached")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Color.appAccent)
                                .clipShape(Capsule())
                        }
                        Image(uiImage: capturedImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 240)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.black.opacity(0.06), lineWidth: 1)
                            )
                        Text("This image will be saved with your roadmap entry and lesson details.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    .padding(24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.black.opacity(0.04), lineWidth: 1)
                    )
                    
                    // --- 2. ROADMAP TITLE INPUT / DROPDOWN ---
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(spacing: 14) {
                            Image(systemName: "map")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color.appAccent)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Roadmap Title")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                Text(selectedRoadmap == nil ? "Create a new roadmap or pick an existing one." : "Selected roadmap will be updated with this entry.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                        }
                        HStack {
                            TextField("e.g., Machining Fundamentals", text: $collectionText, onEditingChanged: { isEditing in
                                withAnimation { isRoadmapDropdownFocused = isEditing }
                            })
                            .onChange(of: collectionText) { _, newValue in
                                if let selected = selectedRoadmap, selected.title != newValue {
                                    selectedRoadmap = nil
                                    selectedMilestone = nil
                                    milestoneTitleText = ""
                                }
                            }
                            .font(.system(size: 15))
                            
                            if selectedRoadmap != nil {
                                Button(action: {
                                    selectedRoadmap = nil
                                    selectedMilestone = nil
                                    collectionText = ""
                                    milestoneTitleText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isRoadmapDropdownFocused ? Color.appAccent : Color.clear, lineWidth: 1.5)
                        )
                        
                        if isRoadmapDropdownFocused && !filteredRoadmaps.isEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(filteredRoadmaps) { roadmap in
                                    Button(action: {
                                        selectedRoadmap = roadmap
                                        collectionText = roadmap.title
                                        isRoadmapDropdownFocused = false
                                        hideKeyboard()
                                    }) {
                                        HStack(spacing: 12) {
                                            Circle()
                                                .fill(Color.fromHex(roadmap.colorHex))
                                                .frame(width: 10, height: 10)
                                            Text(roadmap.title)
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.primary)
                                                .multilineTextAlignment(.leading)
                                                .lineSpacing(3)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 12)
                                    }
                                    if roadmap.id != filteredRoadmaps.last?.id {
                                        Divider().background(Color.primary.opacity(0.06))
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                            .background(Color(.systemGray6))
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
                            )
                            .padding(.top, 4)
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.black.opacity(0.04), lineWidth: 1)
                    )
                    
                    // --- 3. DYNAMIC ROADMAP GOAL DESCRIPTION FIELD ---
                    if selectedRoadmap == nil {
                        VStack(alignment: .leading, spacing: 18) {
                            HStack(spacing: 14) {
                                Image(systemName: "lightbulb")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color.appAccent)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Roadmap Goal Description")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.black)
                                    Text("Describe the learning outcome for this roadmap.")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                            }
                            TextField("A beginner-friendly roadmap for cutting tools, tool geometry...", text: $goalDescriptionText, axis: .vertical)
                                .lineLimit(2...3)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(24)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(Color.black.opacity(0.04), lineWidth: 1)
                        )
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    // --- 4. MILESTONE TITLE INPUT & INCOMPLETE DROPDOWN ---
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(spacing: 14) {
                            Image(systemName: "list.bullet.rectangle")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color.appAccent)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Milestone / Lesson Title")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                Text(collectionText.isEmpty ? "Enter a roadmap title first to enable milestone selection." : "Choose an existing incomplete milestone or start a new one.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                        }
                        HStack {
                            TextField("e.g., Cutting Tool Components", text: $milestoneTitleText, onEditingChanged: { isEditing in
                                withAnimation { isMilestoneDropdownFocused = isEditing }
                            })
                            .disabled(collectionText.isEmpty)
                            .onChange(of: milestoneTitleText) { _, newValue in
                                if let selected = selectedMilestone, selected.title != newValue {
                                    selectedMilestone = nil
                                }
                            }
                            .font(.system(size: 15))
                            
                            if selectedMilestone != nil {
                                Button(action: {
                                    selectedMilestone = nil
                                    milestoneTitleText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(collectionText.isEmpty ? Color(.systemGray5) : Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isMilestoneDropdownFocused ? Color.appAccent : Color.clear, lineWidth: 1.5)
                        )
                        
                        if isMilestoneDropdownFocused && selectedRoadmap != nil && !filteredMilestones.isEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(filteredMilestones) { milestone in
                                    Button(action: {
                                        selectedMilestone = milestone
                                        milestoneTitleText = milestone.title
                                        entriesText = milestone.content
                                        selectedMood = milestone.emotionLevel
                                        isMilestoneDropdownFocused = false
                                        hideKeyboard()
                                    }) {
                                        HStack(alignment: .top, spacing: 12) {
                                            Image(systemName: "circle.dotted")
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(Color.appAccent)
                                                .padding(.top, 2)
                                            Text(milestone.title)
                                                .font(.system(size: 14, weight: .semibold))
                                                .foregroundColor(.primary)
                                                .multilineTextAlignment(.leading)
                                                .lineSpacing(3)
                                            Spacer()
                                        }
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 12)
                                    }
                                    if milestone.id != filteredMilestones.last?.id {
                                        Divider().background(Color.primary.opacity(0.06))
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                            .background(Color(.systemGray6))
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
                            )
                            .padding(.top, 4)
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.black.opacity(0.04), lineWidth: 1)
                    )
                    
                    // --- 5. EXPLANATION DATA RECORD FIELD ---
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(spacing: 14) {
                            Image(systemName: "square.and.pencil")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color.appAccent)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Explanation")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                Text("Write a quick note for how this lesson felt and what you learned.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                        }
                        TextField("Most cutting tools can be understood as variations...", text: $entriesText, axis: .vertical)
                            .focused($isExplanationFocused)
                            .lineLimit(4...8)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isExplanationFocused ? Color.appAccent : Color.clear, lineWidth: 1.5)
                            )
                    }
                    .padding(24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.black.opacity(0.04), lineWidth: 1)
                    )
                    
                    // --- 6. FEELING SCORE MOOD PICKER ---
                    VStack(alignment: .leading, spacing: 18) {
                        HStack(spacing: 14) {
                            Image(systemName: "face.smiling")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color.appAccent)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("How did it feel after finishing this lesson?")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                Text("Tap one leaf to capture your mood.")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }
                        }
                        HStack(spacing: 16) {
                            ForEach(1...5, id: \.self) { index in
                                Button(action: {
                                    selectedMood = index
                                }) {
                                    Image(systemName: "leaf.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(selectedMood == index ? moodColor(for: index) : Color.gray.opacity(0.35))
                                        .scaleEffect(selectedMood == index ? 1.2 : 1.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedMood)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.vertical, 6)
                    }
                    .padding(24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: Color.black.opacity(0.02), radius: 8, x: 0, y: 4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(Color.black.opacity(0.04), lineWidth: 1)
                    )
                    
                    // --- 7. SUBMIT PERSISTENCE ACTION TRIGGER ---
                    VStack(spacing: 12) {
                        Button(action: saveLogEntry) {
                            Text(selectedMilestone != nil ? "🚀 Complete Existing Milestone" : "🌱 Create & Complete New Milestone")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(isFormValid ? Color.appAccent : Color.gray)
                                .clipShape(Capsule())
                        }
                        .disabled(!isFormValid)
                        
                        Text("Your roadmap, milestone, and image will save together in one action.")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 6)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .ignoresSafeArea(edges: .top)
            
            // --- TOP NAVIGATION BAR ---
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 38, height: 38)
                        .background(Color.appAccent)
                        .clipShape(Circle())
                }
                Spacer()
                VStack(spacing: 2) {
                    Text(selectedRoadmap == nil ? "Capture & Save" : "Log Progress")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
                Spacer()
                Color.clear.frame(width: 38, height: 38)
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 12)
            .background(Color.appBackground)
            .overlay(
                VStack {
                    Spacer()
                    Rectangle()
                        .fill(Color.primary.opacity(0.06))
                        .frame(height: 1)
                }
            )
            .ignoresSafeArea(edges: .top)
            }
            .navigationBarHidden(true)
            .navigationDestination(for: Roadmap.self) { roadmap in
                RoadmapDetailView(roadmap: roadmap)
            }
        }
    }
    
    // --- Input Validation Gateway ---
    private var isFormValid: Bool {
        if collectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }
        if selectedRoadmap == nil && goalDescriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }
        if selectedMilestone != nil {
            return true
        }
        if milestoneTitleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            entriesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }
        return true
    }

    // --- TRANSACTION SAVE EXECUTION ---
    private func saveLogEntry() {
        guard isFormValid else { return }
        let photoData = capturedImage.jpegData(compressionQuality: 0.8)
        
        let parentRoadmap: Roadmap
        
        if let existingRoadmap = selectedRoadmap {
            parentRoadmap = existingRoadmap
        } else {
            parentRoadmap = Roadmap(
                title: collectionText,
                goalDescription: goalDescriptionText,
                colorHex: "#9F9E32"
            )
            modelContext.insert(parentRoadmap)
        }
        
        if let targetMilestone = selectedMilestone {
            // SCENARIO A: Updating and completing an existing incomplete milestone selection
            targetMilestone.content = entriesText
            targetMilestone.emotionLevel = selectedMood
            targetMilestone.imageData = photoData
            
            // Set both completion parameters together explicitly!
            targetMilestone.isCompleted = true
            targetMilestone.completedAt = Date()
            
        } else {
            // SCENARIO B: Brand new milestone initialization matching the target class schema
            let newMilestone = Milestone(
                title: milestoneTitleText,
                isCompleted: true, // Mark true directly inside construction
                content: entriesText,
                emotionLevel: selectedMood
            )
            newMilestone.imageData = photoData
            newMilestone.roadmap = parentRoadmap
            newMilestone.completedAt = Date()
            
            if parentRoadmap.milestones.isEmpty {
                parentRoadmap.milestones = [newMilestone]
            } else {
                parentRoadmap.milestones.append(newMilestone)
            }
        }
        
        try? modelContext.save()
        onSaveComplete()
    }
    
    private func moodColor(for index: Int) -> Color {
        switch index {
        case 1: return Color.fromHex("#C5C475") // Light sprout green-yellow
        case 2: return Color.fromHex("#AFAE3C") // Soft olive green
        case 3: return Color.appAccent          // Primary green (#9F9E32)
        case 4: return Color.fromHex("#7F8E3C") // Mid-leaf green
        case 5: return Color.fromHex("#567838") // Rich forest green
        default: return Color.appAccent
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Color {
    static let oliveSprout = Color.appAccent
}
