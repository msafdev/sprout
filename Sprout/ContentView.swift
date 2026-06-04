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
    @AppStorage("isDarkMode") private var isDarkMode = false

    var body: some View {
        Group {
            if hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingScreen()
            }
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

#Preview {
    let _ = UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
    return ContentView()
        .modelContainer(for: [Item.self, Roadmap.self, Milestone.self], inMemory: true)
}
