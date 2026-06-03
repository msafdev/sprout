//
//  EntryView.swift
//  Sprout
//

import SwiftUI
import SwiftData

struct EntryView: View {
    let capturedImage: UIImage
    @Binding var selectedTab: Int // 👈 Added binding to wire up tab switching to the main layout
    var onSaveComplete: () -> Void
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // --- Navigation ---
    @State private var navigationPath = NavigationPath()
    
    // --- SwiftData Query ---
    @Query(sort: \Roadmap.createdAt, order: .reverse) private var existingRoadmaps: [Roadmap]
    
    // --- Dynamic Form Input States ---
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
    
    // --- Validation Helper ---
    private var isFormValid: Bool {
        if collectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
           milestoneTitleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
           entriesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }
        // If it's a new roadmap, also ensure description isn't empty
        if selectedRoadmap == nil && goalDescriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }
        return true
    }
    
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
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(spacing: 0) {
                // --- TOP NAVIGATION BAR ---
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 38, height: 38)
                            .background(Color.oliveSprout.opacity(0.85))
                            .clipShape(Circle())
                    }
                    Spacer()
                    VStack(spacing: 4) {
                        Text(selectedRoadmap == nil ? "Create Journey" : "Log Progress")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.black)
                        Text(selectedRoadmap == nil ? "Start a new roadmap and save your learning snapshot." : "Add a new entry to an existing roadmap.")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Color.clear.frame(width: 38, height: 38)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 16)
                .background(Color.white)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // --- 1. CAPTURED MEDIA WORKSPACE PREVIEW ---
                        VStack(alignment: .leading, spacing: 14) {
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
                                    .background(Color.oliveSprout)
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
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: Color.black.opacity(0.04), radius: 14, x: 0, y: 6)
                        
                        // --- 2. ROADMAP TITLE INPUT / DROPDOWN ---
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 10) {
                                Image(systemName: "map")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color.oliveSprout)
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
                            
                            if isRoadmapDropdownFocused && !filteredRoadmaps.isEmpty {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(filteredRoadmaps) { roadmap in
                                        Button(action: {
                                            selectedRoadmap = roadmap
                                            collectionText = roadmap.title
                                            isRoadmapDropdownFocused = false
                                            hideKeyboard()
                                        }) {
                                            HStack {
                                                Circle()
                                                    .fill(Color.fromHex(roadmap.colorHex))
                                                    .frame(width: 12, height: 12)
                                                Text(roadmap.title)
                                                    .foregroundColor(.black)
                                                Spacer()
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                        }
                                        Divider().padding(.horizontal, 16)
                                    }
                                }
                                .background(Color(.systemBackground))
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: Color.black.opacity(0.04), radius: 14, x: 0, y: 6)
                        
                        // --- 3. DYNAMIC ROADMAP GOAL DESCRIPTION FIELD ---
                        if selectedRoadmap == nil {
                            VStack(alignment: .leading, spacing: 12) {
                                Color.clear.frame(height: 0) // Anchor for layout clean transition
                                HStack(spacing: 10) {
                                    Image(systemName: "lightbulb")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(Color.oliveSprout)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Roadmap Goal Description")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.black)
                                        Text("Describe the learning outcome for this roadmap.")
                                            .font(.system(size: 13))
                                            .foregroundColor(.secondary)
                                    }
                                }
                                TextField("A beginner-friendly roadmap for cutting tools...", text: $goalDescriptionText, axis: .vertical)
                                    .lineLimit(2...3)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(Color(.systemGray6))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                            .padding(20)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(color: Color.black.opacity(0.04), radius: 14, x: 0, y: 6)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        
                        // --- 4. MILESTONE TITLE INPUT & INCOMPLETE DROPDOWN ---
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 10) {
                                Image(systemName: "list.bullet.rectangle")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color.oliveSprout)
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
                                            HStack {
                                                Image(systemName: "circle")
                                                    .foregroundColor(.gray)
                                                Text(milestone.title)
                                                    .foregroundColor(.black)
                                                Spacer()
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                        }
                                        Divider().padding(.horizontal, 16)
                                    }
                                }
                                .background(Color(.systemBackground))
                                .cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: Color.black.opacity(0.04), radius: 14, x: 0, y: 6)
                        
                        // --- 5. EXPLANATION DATA RECORD FIELD ---
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 10) {
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color.oliveSprout)
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
                                .lineLimit(4...8)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: Color.black.opacity(0.04), radius: 14, x: 0, y: 6)
                        
                        // --- 6. FEELING SCORE MOOD PICKER ---
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 10) {
                                Image(systemName: "face.smiling")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color.oliveSprout)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("How did it feel after finishing this lesson?")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.black)
                                    Text("Tap one leaf to capture your mood.")
                                        .font(.system(size: 13))
                                        .foregroundColor(.secondary)
                                }
                            }
                            HStack(spacing: 20) {
                                let moodAssets = ["s_angry", "s_confused", "s_sad", "s_flat", "s_happy"]
                                
                                ForEach(0..<moodAssets.count, id: \.self) { index in
                                        let isSelected = selectedMood == index + 1
                                        
                                        Button(action: {
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                                selectedMood = index + 1
                                            }
                                        }) {
                                            Image(moodAssets[index])
                                                .resizable()
                                                .scaledToFit()
                                                // Selected: 48x48, Non-selected: 36x36
                                                .frame(width: isSelected ? 48 : 36, height: isSelected ? 48 : 36)
                                                // Scaling effect for smooth transition
                                                .scaleEffect(isSelected ? 1.2 : 1.0)
                                                .opacity(isSelected ? 1.0 : 0.6) // Optional: fade non-selected
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                                .padding(.vertical, 10)
                        }
                        .padding(20)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: Color.black.opacity(0.04), radius: 14, x: 0, y: 6)
                        
                        // --- 7. SUBMIT PERSISTENCE ACTION TRIGGER ---
                        VStack(spacing: 12) {
                            Button(action: saveLogEntry) {
                                Text(selectedMilestone != nil ? "🚀 Complete Existing Milestone" : "🌱 Create & Complete New Milestone")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(isFormValid ? Color.oliveSprout : Color.gray)
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
    
    // --- PERSISTENCE HANDLER ACTION ---
    private func saveLogEntry() {
        guard isFormValid else { return }
        
        let rawImageData = capturedImage.jpegData(compressionQuality: 0.8)
        
        if let existingRoadmap = selectedRoadmap {
            if let existingMilestone = selectedMilestone {
                // Scenario A: Complete an existing incomplete milestone
                existingMilestone.content = entriesText
                existingMilestone.emotionLevel = selectedMood
                existingMilestone.imageData = rawImageData
                existingMilestone.isCompleted = true
                existingMilestone.completedAt = Date()
            } else {
                // Scenario B: Create a brand new milestone under an existing Roadmap
                let newMilestone = Milestone(
                    title: milestoneTitleText,
                    isCompleted: true,
                    content: entriesText,
                    emotionLevel: selectedMood,
                    completedAt: Date()
                )
                newMilestone.imageData = rawImageData
                existingRoadmap.milestones.append(newMilestone)
            }
        } else {
            // Scenario C: Create completely new Roadmap with consistent branding
            let finalColor = "#9F9E32" // Use your primary olive green
            
            let newRoadmap = Roadmap(
                title: collectionText,
                goalDescription: goalDescriptionText,
                colorHex: finalColor
            )
            
            let initialMilestone = Milestone(
                title: milestoneTitleText,
                isCompleted: true,
                content: entriesText,
                emotionLevel: selectedMood,
                completedAt: Date()
            )
            initialMilestone.imageData = rawImageData
            
            newRoadmap.milestones.append(initialMilestone)
            modelContext.insert(newRoadmap)
        }
        
        // 1. Commit everything nicely to disk
        try? modelContext.save()
        
        // 2. 🛠️ THE FIX: Force MainTabView to snap to RoadmapScreen (Index 2)
        selectedTab = 2
        
        // 3. Clear our sheet context or overlay wrappers
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
