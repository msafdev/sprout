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
                    DummyScreen(title: "Camera Screen", systemImage: "camera.aperture")
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

struct DummyScreen: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 72))
                .foregroundColor(.primary.opacity(0.3))
            
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary.opacity(0.8))
            
            Text("This screen is under construction.")
                .font(.subheadline)
                .foregroundColor(.primary.opacity(0.8))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    MainTabView()
}
