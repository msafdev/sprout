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
        Group {
            // Screen Contents
            switch selectedTab {
            case 0:
                RecollectScreen()
            case 2:
                // 👇 This MUST be the root screen container carrying the path binding
                RoadmapScreen(navigationPath: $roadmapPath)
            default:
                RoadmapScreen(navigationPath: $roadmapPath)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            CustomTabBar(
                selectedTab: $selectedTab,
                navigationPath: $roadmapPath
            )
        }
        .background(Color.appBackground)
        .ignoresSafeArea(.keyboard)
    }
}
