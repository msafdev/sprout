//
//  CustomTabBar.swift
//  Sprout
//
//  Created by Salman Alfarisi on 25/05/26.
//

import SwiftUI
import SwiftData // 👇 Added for SwiftData model insertions

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Binding var navigationPath: NavigationPath // 👇 Hooked to the MainTabView stack
    
    @Environment(\.modelContext) private var modelContext // 👇 Grabs database context
    
    var onTabTapped: (Int) -> Void = { _ in }

    var body: some View {
        HStack(spacing: 80) {
            ForEach(0..<3, id: \.self) { index in
                if index == 1 {
                    // MARK: - Instant Action Creation Button
                    Button(action: {
                        let roadmap = Roadmap(title: "", goalDescription: "", colorHex: "#9F9E32")
                        
                        // 1. Force screen switch to the Roadmap tab container
                        selectedTab = 2
                        
                        // Clear the navigation path to prevent stacking multiple add screens
                        navigationPath = NavigationPath()
                        
                        // 2. Instantly push the detail view over the stack root
                        navigationPath.append(roadmap)
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color(UIColor.systemBackground))
                            .frame(width: 44, height: 44)
                            .background(Color.appAccent)
                            .clipShape(Circle())
                    }
                    .buttonStyle(EmptyTabButtonStyle())
                } else {
                    // MARK: - Persistent Tab Items (0 and 2)
                    TabBarItem(
                        index: index,
                        selectedTab: $selectedTab,
                        systemName: tabSystemImage(for: index),
                        onTap: {
                            if index == 2 {
                                navigationPath = NavigationPath()
                            }
                            selectedTab = index
                            onTabTapped(index)
                        }
                    )
                }
            }
        }
        .padding(.top, 48)
        .padding(.bottom, 10)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(.systemBackground).opacity(0),
                    Color(.systemBackground),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func tabSystemImage(for index: Int) -> String {
        switch index {
        case 0: return "calendar"
        case 2: return "point.topleft.filled.down.to.point.bottomright.curvepath"
        default: return ""
        }
    }
}

struct TabBarItem: View {
    let index: Int
    @Binding var selectedTab: Int
    let systemName: String
    let onTap: () -> Void

    var isActive: Bool { selectedTab == index }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                Image(systemName: systemName)
                    .font(.system(size: 24, weight: isActive ? .bold : .medium))
                    .foregroundColor(isActive ? Color.appAccent : .primary.opacity(0.5))
                    .frame(height: 28)

                Rectangle()
                    .fill(isActive ? Color.appAccent : Color.clear)
                    .frame(width: 14, height: 2.5)
                    .opacity(isActive ? 1 : 0)
                    .cornerRadius(2)
            }
        }
        .buttonStyle(EmptyTabButtonStyle())
    }
}

struct EmptyTabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
    }
}
