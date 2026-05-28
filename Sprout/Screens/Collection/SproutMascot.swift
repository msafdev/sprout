import SwiftUI

struct SproutMascot: View {
    let accent: Color

    var body: some View {
        ZStack(alignment: .bottom) {
            Circle()
                .fill(accent)
                .frame(width: 86, height: 86)
                .offset(y: 30)

            HStack(spacing: 12) {
                EyeView()
                EyeView()
            }
            .offset(y: 4)

            Capsule()
                .fill(.white)
                .frame(width: 8, height: 28)
                .offset(x: 31, y: 17)

            VStack(spacing: -2) {
                LeafShape()
                    .fill(accent)
                    .frame(width: 22, height: 38)
                    .rotationEffect(.degrees(-34))
                    .offset(x: -8, y: 8)

                LeafShape()
                    .fill(accent)
                    .frame(width: 22, height: 42)
                    .rotationEffect(.degrees(32))
                    .offset(x: 14, y: -16)
            }
            .offset(y: -48)
        }
    }
}

struct EyeView: View {
    var body: some View {
        Circle()
            .fill(.white)
            .frame(width: 13, height: 13)
            .overlay(alignment: .center) {
                Circle()
                    .fill(Color.black.opacity(0.45))
                    .frame(width: 5, height: 5)
            }
    }
}

struct LeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control1: CGPoint(x: rect.minX - rect.width * 0.15, y: rect.height * 0.62),
            control2: CGPoint(x: rect.minX, y: rect.height * 0.10)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control1: CGPoint(x: rect.maxX, y: rect.height * 0.10),
            control2: CGPoint(x: rect.maxX + rect.width * 0.15, y: rect.height * 0.62)
        )
        return path
    }
}

struct MiniProgressBar: View {
    let progress: Double
    let accent: Color

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.black.opacity(0.08))

                Capsule()
                    .fill(accent)
                    .frame(width: proxy.size.width * progress)
            }
        }
        .frame(height: 5)
    }
}
