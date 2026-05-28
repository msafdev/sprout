//
//  EntryView.swift
//  Sprout
//

import SwiftUI

struct EntryView: View {
    let capturedImage: UIImage
    @Environment(\.dismiss) var dismiss
    
    // Form Input States
    @State private var collectionText: String = ""
    @State private var entriesText: String = ""
    @State private var selectedMood: Int = 2 // Defaulting to the green sprout index
    
    // Mock Data for Search Dropdowns (Simulating your Table View mockups)
    let collectionSuggestions = ["Suggestion 1", "Suggestion 2", "Suggestion 3", "Suggestion 4", "Suggestion 5"]
    let roadmapSuggestions = ["Roadmap 1", "Roadmap 2", "Roadmap 3"]
    
    var body: some View {
        VStack(spacing: 0) {
            // --- TOP BAR ---
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 38, height: 38)
                        .background(Color.oliveSprout.opacity(0.8)) // Matching the theme accent color
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text("Title")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                
                Spacer()
                
                // Visual balancer empty block matching design symmetry
                Color.clear.frame(width: 38, height: 38)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 16)
            .background(Color.white)
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // --- 1. CAPTURED IMAGE VIEW WINDOW ---
                    Image(uiImage: capturedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 220, height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .frame(maxWidth: .infinity, alignment: .center) // Aligns centered horizontally
                        .padding(.top, 12)
                    
                    // --- 2. COLLECTION SECTION ---
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Collection")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        TextField("Enter skill collection", text: $collectionText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color(.systemGray6))
                            .clipShape(Capsule())
                    }
                    
                    // --- 3. ENTRIES SECTION ---
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Entries")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        TextField("Add your roadmap here", text: $entriesText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color(.systemGray6))
                            .clipShape(Capsule())
                    }
                    
                    // --- 4. HOW DID IT FEEL / MOOD PICKER SECTION ---
                    VStack(alignment: .leading, spacing: 12) {
                        Text("How did it feel?")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        HStack(spacing: 16) {
                            ForEach(0..<5) { index in
                                Button(action: {
                                    selectedMood = index
                                }) {
                                    // Sprout character asset variants template mapping
                                    Image(systemName: "leaf.fill") // Replace with "sprout_mood_\(index)" when assets arrive
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
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 120) // Give bottom space padding for custom tab bar overlay floating gap
            }
        }
        .navigationBarHidden(true)
        .overlay(alignment: .bottom) {
            // --- CUSTOM INSET CUSTOM TAB NAVIGATION BAR HOOK ---
            CustomBottomBar()
        }
    }
}

// Delete or Change Later
// MARK: - EXTRACTED DESIGN COMPONENTS
struct CustomBottomBar: View {
    var body: some View {
        HStack {
            VStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.system(size: 20))
                Text("recollectio")
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(.gray.opacity(0.6))
            .frame(maxWidth: .infinity)
            
            // Central floating primary add shortcut button matching layout frame bounds
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                .frame(width: 70, height: 70)
                .background(Color.white.clipShape(Circle()))
                .overlay(
                    Image(systemName: "camera")
                        .font(.system(size: 22))
                        .foregroundColor(.oliveSprout)
                )
                .offset(y: -25)
            
            VStack(spacing: 4) {
                Image(systemName: "square.stack.3d.up.fill")
                    .font(.system(size: 20))
                Text("Collection")
                    .font(.system(size: 10, weight: .medium))
            }
            .foregroundColor(.gray.opacity(0.6))
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: -4)
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }
}

// Custom Accent Extensions Color Palette Setup
extension Color {
    static let oliveSprout = Color(red: 140/255, green: 162/255, blue: 64/255) // Custom tone matching wireframe sprout selection item accent
}
