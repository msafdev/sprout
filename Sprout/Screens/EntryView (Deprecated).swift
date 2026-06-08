////
////  EntryView.swift
////  Sprout
////
//
//import SwiftUI
//import SwiftData
//
//struct EntryView: View {
//    let capturedImage: UIImage
//    @Binding var selectedTab: Int
//    var onSaveComplete: () -> Void
//
//    @Environment(\.modelContext) private var modelContext
//    @Environment(\.dismiss) private var dismiss
//
//    @Query(sort: \Roadmap.createdAt, order: .reverse) private var existingRoadmaps: [Roadmap]
//
//    @State private var collectionText: String = ""
//    @State private var goalDescriptionText: String = ""
//    @State private var milestoneTitleText: String = ""
//    @State private var entriesText: String = ""
//    @State private var selectedMood: Int = 3
//
//    @State private var selectedRoadmap: Roadmap? = nil
//    @State private var selectedMilestone: Milestone? = nil
//
//    @State private var isRoadmapDropdownFocused: Bool = false
//    @State private var isMilestoneDropdownFocused: Bool = false
//
//    private let moodAssets = ["s_angry", "s_confused", "s_sad", "s_flat", "s_happy"]
//
//    private var isFormValid: Bool {
//        if collectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
//           milestoneTitleText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
//           entriesText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//            return false
//        }
//        if selectedRoadmap == nil && goalDescriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
//            return false
//        }
//        return true
//    }
//
//    var filteredRoadmaps: [Roadmap] {
//        if collectionText.isEmpty { return existingRoadmaps }
//        return existingRoadmaps.filter { $0.title.localizedCaseInsensitiveContains(collectionText) }
//    }
//
//    var filteredMilestones: [Milestone] {
//        guard let roadmap = selectedRoadmap else { return [] }
//        let incomplete = roadmap.milestones.filter { !$0.isCompleted }
//        if milestoneTitleText.isEmpty {
//            return incomplete.sorted { $0.createdAt < $1.createdAt }
//        }
//        return incomplete.filter { $0.title.localizedCaseInsensitiveContains(milestoneTitleText) }
//            .sorted { $0.createdAt < $1.createdAt }
//    }
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 24) {
//
//                // Main Card
//                VStack(alignment: .leading, spacing: 20) {
//
//                    // Photo
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Photo")
//                            .font(.caption).fontWeight(.bold).foregroundColor(.gray)
//                        Image(uiImage: capturedImage)
//                            .resizable()
//                            .aspectRatio(4/3, contentMode: .fill)
//                            .frame(maxWidth: .infinity)
//                            .clipShape(RoundedRectangle(cornerRadius: 14))
//                    }
//
//                    Divider()
//
//                    // Collection
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Roadmap")
//                            .font(.caption).fontWeight(.bold).foregroundColor(.gray)
//                        HStack {
//                            TextField("e.g., Machining Fundamentals", text: $collectionText, onEditingChanged: { isEditing in
//                                withAnimation { isRoadmapDropdownFocused = isEditing }
//                            })
//                            .onChange(of: collectionText) { _, newValue in
//                                if let selected = selectedRoadmap, selected.title != newValue {
//                                    selectedRoadmap = nil
//                                    selectedMilestone = nil
//                                    milestoneTitleText = ""
//                                }
//                            }
//                            .font(.body)
//                            .textFieldStyle(PlainTextFieldStyle())
//
//                            if selectedRoadmap != nil {
//                                Button(action: {
//                                    selectedRoadmap = nil
//                                    selectedMilestone = nil
//                                    collectionText = ""
//                                    milestoneTitleText = ""
//                                }) {
//                                    Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
//                                }
//                            }
//                        }
//
//                        if isRoadmapDropdownFocused && !filteredRoadmaps.isEmpty {
//                            VStack(alignment: .leading, spacing: 0) {
//                                ForEach(filteredRoadmaps) { roadmap in
//                                    Button(action: {
//                                        selectedRoadmap = roadmap
//                                        collectionText = roadmap.title
//                                        isRoadmapDropdownFocused = false
//                                        hideKeyboard()
//                                    }) {
//                                        HStack {
//                                            Circle().fill(Color.fromHex(roadmap.colorHex)).frame(width: 12, height: 12)
//                                            Text(roadmap.title).foregroundColor(.primary)
//                                            Spacer()
//                                        }
//                                        .padding(.horizontal, 12)
//                                        .padding(.vertical, 10)
//                                    }
//                                    Divider()
//                                }
//                            }
//                            .background(Color(.systemBackground))
//                            .cornerRadius(12)
//                            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
//                        }
//                    }
//
//                    // Goal Description (new roadmap only)
//                    if selectedRoadmap == nil {
//                        Divider()
//                        VStack(alignment: .leading, spacing: 8) {
//                            Text("Roadmap's Description")
//                                .font(.caption).fontWeight(.bold).foregroundColor(.gray)
//                            TextField("Describe the learning outcome for this roadmap.", text: $goalDescriptionText, axis: .vertical)
//                                .lineLimit(2...4)
//                                .font(.body)
//                                .textFieldStyle(PlainTextFieldStyle())
//                        }
//                        .transition(.opacity.combined(with: .move(edge: .top)))
//                    }
//
//                    Divider()
//
//                    // Milestone
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Milestone")
//                            .font(.caption).fontWeight(.bold).foregroundColor(.gray)
//                        HStack {
//                            TextField(
//                                collectionText.isEmpty ? "Enter a collection first" : "e.g., Cutting Tool Components",
//                                text: $milestoneTitleText,
//                                onEditingChanged: { isEditing in
//                                    withAnimation { isMilestoneDropdownFocused = isEditing }
//                                }
//                            )
//                            .disabled(collectionText.isEmpty)
//                            .onChange(of: milestoneTitleText) { _, newValue in
//                                if let selected = selectedMilestone, selected.title != newValue {
//                                    selectedMilestone = nil
//                                }
//                            }
//                            .font(.body)
//                            .textFieldStyle(PlainTextFieldStyle())
//                            .foregroundColor(collectionText.isEmpty ? .secondary : .primary)
//
//                            if selectedMilestone != nil {
//                                Button(action: {
//                                    selectedMilestone = nil
//                                    milestoneTitleText = ""
//                                }) {
//                                    Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
//                                }
//                            }
//                        }
//
//                        if isMilestoneDropdownFocused && selectedRoadmap != nil && !filteredMilestones.isEmpty {
//                            VStack(alignment: .leading, spacing: 0) {
//                                ForEach(filteredMilestones) { milestone in
//                                    Button(action: {
//                                        selectedMilestone = milestone
//                                        milestoneTitleText = milestone.title
//                                        entriesText = milestone.content
//                                        selectedMood = milestone.emotionLevel
//                                        isMilestoneDropdownFocused = false
//                                        hideKeyboard()
//                                    }) {
//                                        HStack {
//                                            Image(systemName: "circle").foregroundColor(.gray)
//                                            Text(milestone.title).foregroundColor(.primary)
//                                            Spacer()
//                                        }
//                                        .padding(.horizontal, 12)
//                                        .padding(.vertical, 10)
//                                    }
//                                    Divider()
//                                }
//                            }
//                            .background(Color(.systemBackground))
//                            .cornerRadius(12)
//                            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
//                        }
//                    }
//
//                    Divider()
//
//                    // Explanation
//                    VStack(alignment: .leading, spacing: 8) {
//                        Text("Explanation")
//                            .font(.caption).fontWeight(.bold).foregroundColor(.gray)
//                        TextField("Write your explanation here...", text: $entriesText, axis: .vertical)
//                            .lineLimit(4...)
//                            .font(.body)
//                            .textFieldStyle(PlainTextFieldStyle())
//                    }
//
//                    Divider()
//
//                    // Emotion
//                    VStack(alignment: .leading, spacing: 12) {
//                        Text("How did you feel?")
//                            .font(.caption).fontWeight(.bold).foregroundColor(.gray)
//                        HStack(spacing: 0) {
//                            ForEach(1...5, id: \.self) { level in
//                                let isSelected = selectedMood == level
//                                Button(action: {
//                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
//                                        selectedMood = level
//                                    }
//                                }) {
//                                    Image(moodAssets[level - 1])
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: isSelected ? 48 : 36, height: isSelected ? 48 : 36)
//                                        .scaleEffect(isSelected ? 1.1 : 1.0)
//                                        .opacity(isSelected ? 1.0 : 0.45)
//                                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedMood)
//                                }
//                                .frame(maxWidth: .infinity)
//                            }
//                        }
//                        .frame(maxWidth: .infinity)
//                    }
//                }
//                .padding(20)
//                .background(Color.appCard)
//                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
//                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
//
//                // Save Button
//                Button(action: saveLogEntry) {
//                    Text(selectedMilestone != nil ? "Complete Existing Milestone" : "Create & Complete Milestone")
//                        .font(.system(size: 16, weight: .bold))
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .padding(.vertical, 16)
//                        .background(isFormValid ? Color.appAccent : Color.gray.opacity(0.4))
//                        .clipShape(Capsule())
//                }
//                .disabled(!isFormValid)
//            }
//            .padding(.horizontal, 20)
//            .padding(.bottom, 28)
//        }
//        .safeAreaInset(edge: .top, spacing: 0) {
//            HStack {
//                Button(action: { dismiss() }) {
//                    Image(systemName: "chevron.left")
//                        .font(.system(size: 16, weight: .bold))
//                        .foregroundColor(.primary)
//                        .frame(width: 44, height: 44)
//                        .background(Color.primary.opacity(0.08))
//                        .clipShape(Circle())
//                }
//
//                Spacer()
//
//                Text(selectedRoadmap == nil ? "Create Roadmap" : "Log Progress")
//                    .font(.system(size: 17, weight: .semibold))
//                    .foregroundColor(.primary)
//
//                Spacer()
//
//                Color.clear.frame(width: 44, height: 44)
//            }
//            .padding(.horizontal, 20)
//            .padding(.top, 20)
//            .padding(.bottom, 8)
//            .background(Color.appBackground)
//        }
//        .background(Color.appBackground)
//        .navigationBarHidden(true)
//    }
//
//    private func saveLogEntry() {
//        guard isFormValid else { return }
//
//        let rawImageData = capturedImage.jpegData(compressionQuality: 0.8)
//
//        if let existingRoadmap = selectedRoadmap {
//            if let existingMilestone = selectedMilestone {
//                existingMilestone.content = entriesText
//                existingMilestone.emotionLevel = selectedMood
//                existingMilestone.imageData = rawImageData
//                existingMilestone.isCompleted = true
//                existingMilestone.completedAt = Date()
//            } else {
//                let newMilestone = Milestone(
//                    title: milestoneTitleText,
//                    isCompleted: true,
//                    content: entriesText,
//                    emotionLevel: selectedMood,
//                    completedAt: Date()
//                )
//                newMilestone.imageData = rawImageData
//                existingRoadmap.milestones.append(newMilestone)
//            }
//        } else {
//            let newRoadmap = Roadmap(
//                title: collectionText,
//                goalDescription: goalDescriptionText,
//                colorHex: "#9F9E32"
//            )
//            let initialMilestone = Milestone(
//                title: milestoneTitleText,
//                isCompleted: true,
//                content: entriesText,
//                emotionLevel: selectedMood,
//                completedAt: Date()
//            )
//            initialMilestone.imageData = rawImageData
//            newRoadmap.milestones.append(initialMilestone)
//            modelContext.insert(newRoadmap)
//        }
//
//        try? modelContext.save()
//        selectedTab = 2
//        onSaveComplete()
//    }
//
//    private func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
//}
//
//extension Color {
//    static let oliveSprout = Color.appAccent
//}
