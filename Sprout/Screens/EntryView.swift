//
//  EntryView.swift
//  Sprout
//

import SwiftUI
import SwiftData

struct EntryView: View {
    let capturedImage: UIImage
    @Binding var selectedTab: Int
    var onSaveComplete: () -> Void

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Roadmap.createdAt, order: .reverse) private var existingRoadmaps: [Roadmap]

    @State private var collectionText: String = ""
    @State private var goalDescriptionText: String = ""
    @State private var milestoneTitleText: String = ""
    @State private var entriesText: String = ""
    @State private var selectedMood: Int = 3

    @State private var selectedRoadmap: Roadmap? = nil
    @State private var selectedMilestone: Milestone? = nil

    @State private var isRoadmapDropdownFocused: Bool = false
    @State private var isMilestoneDropdownFocused: Bool = false

    private let moodAssets = ["s_angry", "s_confused", "s_sad", "s_flat", "s_happy"]

    private var isFormValid: Bool {
        if collectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
           milestoneTitleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
           entriesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }
        if selectedRoadmap == nil && goalDescriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return false
        }
        return true
    }

    var filteredRoadmaps: [Roadmap] {
        if collectionText.isEmpty { return existingRoadmaps }
        return existingRoadmaps.filter { $0.title.localizedCaseInsensitiveContains(collectionText) }
    }

    var filteredMilestones: [Milestone] {
        guard let roadmap = selectedRoadmap else { return [] }
        let incomplete = roadmap.milestones.filter { !$0.isCompleted }
        if milestoneTitleText.isEmpty {
            return incomplete.sorted { $0.createdAt < $1.createdAt }
        }
        return incomplete.filter { $0.title.localizedCaseInsensitiveContains(milestoneTitleText) }
            .sorted { $0.createdAt < $1.createdAt }
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
                            .foregroundColor(.primary)
                            .frame(width: 44, height: 44)
                            .background(Color.primary.opacity(0.06))
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
                                .foregroundColor(.primary)
                                
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
                                                    .foregroundColor(.primary)
                                                Spacer()
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 12)
                                        }
                                        Divider().padding(.horizontal, 16)
                                    }
                                    Divider()
                                }
                                .background(Color.appCard)
                                .cornerRadius(16)
                                .shadow(color: Color.primary.opacity(0.08), radius: 12, x: 0, y: 6)
                            }
                        }
                        .padding(20)
                        .background(Color.appCard)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: Color.primary.opacity(0.04), radius: 14, x: 0, y: 6)
                        
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
                                            .foregroundColor(.primary)
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
                            .background(Color.appCard)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                            .shadow(color: Color.primary.opacity(0.04), radius: 14, x: 0, y: 6)
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
                                        .foregroundColor(.primary)
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
                                                    .foregroundColor(.primary)
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
                                .shadow(color: Color.primary.opacity(0.08), radius: 12, x: 0, y: 6)
                            }
                        }
                        .padding(20)
                        .background(Color.appCard)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: Color.primary.opacity(0.04), radius: 14, x: 0, y: 6)
                        
                        // --- 5. EXPLANATION DATA RECORD FIELD ---
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 10) {
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color.oliveSprout)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Explanation")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.appPrimary)
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
                        .background(Color.appCard)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: Color.primary.opacity(0.04), radius: 14, x: 0, y: 6)
                        
                        // --- 6. FEELING SCORE MOOD PICKER ---
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 10) {
                                Image(systemName: "face.smiling")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(Color.oliveSprout)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("How did it feel after finishing this lesson?")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.primary)
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
                        .background(Color.appCard)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .shadow(color: Color.primary.opacity(0.04), radius: 14, x: 0, y: 6)
                        
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
        }
        .navigationBarHidden(true)
    }
    
    // --- PERSISTENCE HANDLER ACTION ---
    private func saveLogEntry() {
        guard isFormValid else { return }

        let rawImageData = capturedImage.jpegData(compressionQuality: 0.8)

        if let existingRoadmap = selectedRoadmap {
            if let existingMilestone = selectedMilestone {
                existingMilestone.content = entriesText
                existingMilestone.emotionLevel = selectedMood
                existingMilestone.imageData = rawImageData
                existingMilestone.isCompleted = true
                existingMilestone.completedAt = Date()
            } else {
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
            let newRoadmap = Roadmap(
                title: collectionText,
                goalDescription: goalDescriptionText,
                colorHex: "#9F9E32"
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

        try? modelContext.save()
        
        // 2. 🛠️ THE FIX: Force MainTabView to snap to RoadmapScreen (Index 2)
        selectedTab = 2
        onSaveComplete()
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Color {
    static let oliveSprout = Color.appAccent
}
