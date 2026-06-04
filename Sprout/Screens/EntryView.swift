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
            AppGradientBackground()
            
            VStack(spacing: 16) {
                // --- TOP NAVIGATION ---
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.06))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // Olive Green Save Button - Changes opacity depending on form validity
                    Button(action: {
                        saveLogEntry()
                    }) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color(red: 0.65, green: 0.70, blue: 0.30).opacity(isFormValid ? 1.0 : 0.4))
                            .clipShape(Circle())
                    }
                    .disabled(!isFormValid)
                }
                .padding(.horizontal, 24)
                .padding(.top, 10)
                
                // --- SINGLE UNIFIED CONTENT CARD ---
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // 1. ROADMAP TRACKING SECTION
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Roadmap")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.gray.opacity(0.7))
                            
                            HStack {
                                TextField("e.g., Machining Fundamentals", text: $collectionText, onEditingChanged: { isEditing in
                                    withAnimation { isRoadmapDropdownFocused = isEditing }
                                })
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                                
                                if selectedRoadmap != nil {
                                    Button(action: {
                                        selectedRoadmap = nil
                                        selectedMilestone = nil
                                        collectionText = ""
                                        milestoneTitleText = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill").foregroundColor(.gray.opacity(0.6))
                                    }
                                }
                            }
                            
                            // Inline Suggestion Dropdown for Existing Roadmaps
                            if isRoadmapDropdownFocused && !filteredRoadmaps.isEmpty {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(filteredRoadmaps) { roadmap in
                                        Button(action: {
                                            selectedRoadmap = roadmap
                                            collectionText = roadmap.title
                                            isRoadmapDropdownFocused = false
                                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        }) {
                                            HStack {
                                                Text(roadmap.title)
                                                    .font(.system(size: 15, weight: .medium))
                                                    .foregroundColor(.black)
                                                Spacer()
                                                Image(systemName: "arrow.up.left.circle").foregroundColor(.gray)
                                            }
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 4)
                                        }
                                        Divider()
                                    }
                                }
                                .padding(.top, 6)
                            }
                        }
                        
                        // Dynamic Goal Description Input (Shown only if creating a new Roadmap)
                        if selectedRoadmap == nil {
                            Divider().background(Color.gray.opacity(0.15))
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Roadmap Goal Description")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.gray.opacity(0.7))
                                
                                TextField("Describe the ultimate target of this track...", text: $goalDescriptionText, axis: .vertical)
                                    .font(.system(size: 15))
                                    .foregroundColor(.black)
                            }
                        }
                        
                        Divider().background(Color.gray.opacity(0.15))
                        
                        // 2. LESSON / MILESTONE TITLE SECTION
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Lesson Title")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.gray.opacity(0.7))
                            
                            HStack {
                                TextField("Enter lesson title", text: $milestoneTitleText, onEditingChanged: { isEditing in
                                    withAnimation { isMilestoneDropdownFocused = isEditing }
                                })
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                                
                                if selectedMilestone != nil {
                                    Button(action: {
                                        selectedMilestone = nil
                                        milestoneTitleText = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill").foregroundColor(.gray.opacity(0.6))
                                    }
                                }
                            }
                            
                            // Inline Suggestion Dropdown for Incomplete Milestones
                            if isMilestoneDropdownFocused && selectedRoadmap != nil && !filteredMilestones.isEmpty {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(filteredMilestones) { milestone in
                                        Button(action: {
                                            selectedMilestone = milestone
                                            milestoneTitleText = milestone.title
                                            entriesText = milestone.content
                                            selectedMood = milestone.emotionLevel
                                            isMilestoneDropdownFocused = false
                                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        }) {
                                            HStack {
                                                Text(milestone.title)
                                                    .font(.system(size: 15, weight: .medium))
                                                    .foregroundColor(.black)
                                                Spacer()
                                                Text("Pending")
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundColor(.orange)
                                            }
                                            .padding(.vertical, 10)
                                            .padding(.horizontal, 4)
                                        }
                                        Divider()
                                    }
                                }
                                .padding(.top, 6)
                            }
                        }
                        
                        Divider().background(Color.gray.opacity(0.15))
                        
                        // 3. BOUNDED PHOTO PREVIEW (Prevents screen blowout)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Photo")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.gray.opacity(0.7))
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.05))
                                .frame(height: 260)
                                .frame(maxWidth: .infinity)
                                .overlay(
                                    Image(uiImage: capturedImage)
                                        .resizable()
                                        .scaledToFill()
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .clipped()
                        }
                        
                        Divider().background(Color.gray.opacity(0.15))
                        
                        // 4. LESSON EXPLANATION FIELD
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Explanation")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.gray.opacity(0.7))
                            
                            TextField("Write your explanation here...", text: $entriesText, axis: .vertical)
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.black)
                                .frame(minHeight: 70, alignment: .top)
                        }
                        
                        Divider().background(Color.gray.opacity(0.15))
                        
                        // 5. ASSET-BASED EMOTION PICKER
                        VStack(alignment: .leading, spacing: 14) {
                            Text("How did you feel?")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.gray.opacity(0.7))
                            
                            HStack(spacing: 16) {
                                let moodAssets = ["s_angry", "s_confused", "s_sad", "s_flat", "s_happy"]
                                
                                ForEach(0..<moodAssets.count, id: \.self) { index in
                                    let level = index + 1
                                    let isSelected = selectedMood == level
                                    
                                    Button(action: {
                                        selectedMood = level
                                    }) {
                                        Image(moodAssets[index])
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 36, height: 36)
                                            .scaleEffect(isSelected ? 1.2 : 1.0)
                                            .opacity(isSelected ? 1.0 : 0.45)
                                            // The animation modifier goes here, tied to the selectedMood state
                                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedMood)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .shadow(color: Color.black.opacity(0.02), radius: 12, x: 0, y: 4)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
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
        
        // 2. Force MainTabView to snap to RoadmapScreen (Index 2)
        selectedTab = 2
        
        // 3. Clear our sheet context or overlay wrappers
        onSaveComplete()
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Color {
    static let oliveSprout = Color.appAccent
}
