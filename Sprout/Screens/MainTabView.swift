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
                RoadmapScreen(navigationPath: $roadmapPath)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .safeAreaInset(edge: .bottom) {
            if selectedTab != 1 {
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .background(Color.appBackground)
        .ignoresSafeArea(.keyboard)
    }
}
