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
        Group{
            if hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingScreen()
            }
        }
        .onAppear {
            // FOR TESTING ONLY: Force this to false every time the view loads
                        hasSeenOnboarding = false
        }
    }
    
}

#Preview {
    let _ = UserDefaults.standard.set(false, forKey: "hasSeenOnboarding")
    return ContentView()
        .modelContainer(for: [Item.self, Roadmap.self, Milestone.self], inMemory: true)
}
