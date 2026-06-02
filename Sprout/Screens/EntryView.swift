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
        VStack(spacing: 0) {
            // --- TOP NAVIGATION BAR ---
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 44, height: 44)
                        .background(Color.primary.opacity(0.08))
                        .clipShape(Circle())
                }
                Spacer()
                Text(selectedRoadmap == nil ? "Create Journey" : "Log Progress")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                Color.clear.frame(width: 38, height: 38)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 16)
            .background(Color.appBackground)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // --- 1. CAPTURED MEDIA WORKSPACE PREVIEW ---
                    Image(uiImage: capturedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 220, height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 12)
                    
                    // --- 2. ROADMAP TITLE INPUT / DROPDOWN ---
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Roadmap Title")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                        
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
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        
                        // Live Auto-Suggestion Roadmap Dropdown
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
                            .cornerRadius(14)
                            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                        }
                    }
                    
                    // --- 3. DYNAMIC ROADMAP GOAL DESCRIPTION FIELD ---
                    if selectedRoadmap == nil {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Roadmap Goal Description")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                            
                            TextField("A beginner-friendly roadmap for cutting tools, tool geometry...", text: $goalDescriptionText, axis: .vertical)
                                .lineLimit(2...3)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    // --- 4. MILESTONE TITLE INPUT & INCOMPLETE DROPDOWN ---
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Milestone / Lesson Title")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                        
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
                        .background(collectionText.isEmpty ? Color(.systemGray4) : Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        
                        // Live Suggestion Dropdown
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
                            .cornerRadius(14)
                            .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                        }
                    }
                    
                    // --- 5. EXPLANATION DATA RECORD FIELD ---
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Explanation")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                        
                        TextField("Most cutting tools can be understood as variations...", text: $entriesText, axis: .vertical)
                            .lineLimit(4...8)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    
                    // --- 6. FEELING SCORE MOOD PICKER ---
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How did it feel after finishing this lesson?")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                        
                        HStack(spacing: 16) {
                            ForEach(1...5, id: \.self) { index in
                                Button(action: {
                                    selectedMood = index
                                }) {
                                    Image(systemName: "leaf.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(selectedMood == index ? Color.oliveSprout : Color.gray.opacity(0.4))
                                        .scaleEffect(selectedMood == index ? 1.2 : 1.0)
                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedMood)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    // --- 7. SUBMIT PERSISTENCE ACTION TRIGGER ---
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
                    .padding(.top, 12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
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
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Color {
    static let oliveSprout = Color.appAccent
}
