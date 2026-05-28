//
//  SkyLearningBackground.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//
import SwiftUI
struct SkyLearningBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color.fromHex("#DDF5FF"),
                Color.fromHex("#F7FBFF"),
                Color.fromHex("#EAF4F7")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(.white.opacity(0.5))
                .frame(width: 230, height: 230)
                .blur(radius: 24)
                .offset(x: 80, y: -70)
        }
        .overlay(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 999, style: .continuous)
                .fill(Color.white.opacity(0.34))
                .frame(width: 220, height: 70)
                .blur(radius: 10)
                .offset(x: -40, y: 92)
        }
    }
}
