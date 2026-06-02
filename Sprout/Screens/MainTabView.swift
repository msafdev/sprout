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
            case 1:
                CameraScreen(selectedTab: $selectedTab)
            case 2:
                RoadmapScreen(navigationPath: $roadmapPath)
            default:
                RecollectScreen()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            if selectedTab != 1 && !(selectedTab == 2 && !roadmapPath.isEmpty) {
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .background(Color.appBackground)
        .ignoresSafeArea(.keyboard)
    }
}
