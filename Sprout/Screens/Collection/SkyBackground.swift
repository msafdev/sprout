import SwiftUI

struct SkyLearningBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "#DDF5FF"),
                Color(hex: "#F7FBFF"),
                Color(hex: "#EAF4F7")
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

struct SkyLearningHeaderBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "#DDF5FF"),
                Color(hex: "#EEF9FF")
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
