//
//  Onboarding.swift
//  Sprout
//
//  Created by Gusti Sandyaga Putra Wardhana on 26/05/26.
//

import SwiftUI
import SwiftData

public struct Onboarding: View {
    
    public var body: some View {
        // 1. Wrap everything inside a NavigationStack so the NavigationLink functions
        NavigationStack {
            // 2. Wrap all detached elements inside a single container VStack
            VStack {
                Spacer()
                
                // --- Top Section: Image and Text ---
                VStack {
                    Image("sprout")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .padding(.bottom, 10)
                    
                    Text("Document your\nfirst progress with\nSprout!")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                // --- Middle Section: Subtext and Arrow ---
                VStack {
                    Text("Let's capture it!")
                        .font(.system(size: 23, weight: .light))
                        .padding(.bottom, 15)
                    Image(systemName: "arrow.down")
                        .font(.system(size: 25, weight: .regular))
                        .padding(.bottom, 15)
                }
                
                // --- Bottom Section: Camera Button ---
                NavigationLink(destination: CameraScreen()) {
                    Image(systemName: "camera")
                        .font(.system(size: 40, weight: .regular))
                        .foregroundColor(.black.opacity(0.9))
                        .frame(width: 100, height: 100)
                        .background(Color.white.clipShape(Circle()))
                        .shadow(color: Color.black.opacity(0.25), radius: 15, x: 0, y: 0)
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
            }
        }
    }
}

#Preview {
    Onboarding()
}
