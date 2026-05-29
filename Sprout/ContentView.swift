//
//  ContentView.swift
//  Sprout
//
//  Created by Salman Alfarisi on 25/05/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        if hasSeenOnboarding {
            MainTabView()
        } else {
            OnboardingScreen()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Item.self, Roadmap.self, Milestone.self], inMemory: true)
}
