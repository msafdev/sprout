//
//  MainTabView.swift
//  Sprout
//
//  Created by Salman Alfarisi on 25/05/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 2
    @State private var roadmapPath = NavigationPath()

    var body: some View {
        ZStack(alignment: .bottom) {
            // MARK: - Layer 1: Screen Contents
            // Your navigation stacks sit in the background and take up the full screen
            Group {
                switch selectedTab {
                case 0:
                    RecollectScreen()
                case 2:
                    RoadmapScreen(navigationPath: $roadmapPath)
                default:
                    RoadmapScreen(navigationPath: $roadmapPath)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // MARK: - Layer 2: Floating Tab Bar
            // This sits on top, totally independent of the navigation stack's layout rules
            CustomTabBar(
                selectedTab: $selectedTab,
                navigationPath: $roadmapPath
            )
        }
        .background(Color.appBackground)
        .ignoresSafeArea(.keyboard)
    }
}
