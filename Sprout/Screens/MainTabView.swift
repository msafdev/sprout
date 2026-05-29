//
//  MainTabView.swift
//  Sprout
//
//  Created by Salman Alfarisi on 25/05/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Screen Contents
            Group {
                switch selectedTab {
                case 0:
                    RecollectScreen()
                case 1:
                    CameraScreen()
                case 2:
                    RoadmapScreen()
                default:
                    RecollectScreen()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            CustomTabBar(selectedTab: $selectedTab)
        }
        .background(Color(.systemBackground))
        .ignoresSafeArea(.keyboard)
    }
}
