//
//  SkyLearningHeaderBackground.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//

import SwiftUI
struct SkyLearningHeaderBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.fromHex("#DDF5FF"),
                Color.fromHex("#EEF9FF")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(.white.opacity(0.42))
                .frame(width: 220, height: 220)
                .blur(radius: 24)
                .offset(x: 80, y: -76)
        }
    }
}
