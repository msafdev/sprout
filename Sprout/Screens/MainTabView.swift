//
//  MainTabView.swift
//  Sprout
//
//  Created by Salman Alfarisi on 25/05/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @State private var roadmapPath = NavigationPath()

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch selectedTab {
                case 0:
                    RecollectScreen()
                case 1:
                    CameraScreen()
                case 2:
                    RoadmapScreen(navigationPath: $roadmapPath)
                default:
                    RecollectScreen()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            CustomTabBar(selectedTab: $selectedTab) { tappedTab in
                if tappedTab == 2 {
                    // Always reset roadmap navigation when roadmap tab is tapped
                    roadmapPath = NavigationPath()
                }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedTab = tappedTab
                }
            }
        }
        .background(Color.appBackground)
        .ignoresSafeArea(.keyboard)
    }
}
