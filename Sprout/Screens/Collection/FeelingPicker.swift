import SwiftUI

struct FeelingPicker: View {
    @Binding var selectedScore: Int?
    let accent: Color

    var body: some View {
        HStack(spacing: 13) {
            ForEach(0..<5, id: \.self) { score in
                Button {
                    withAnimation(.snappy(duration: 0.22)) {
                        selectedScore = score
                    }
                } label: {
                    FeelingIcon(score: score, isSelected: selectedScore == score, accent: accent)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.035))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

struct FeelingIcon: View {
    let score: Int
    let isSelected: Bool
    let accent: Color

    private var faceColor: Color {
        isSelected ? accent : Color.black.opacity(0.18)
    }

    private var mouth: MouthShape.Kind {
        switch score {
        case 0: return .frown
        case 1: return .neutral
        case 2: return .smallSmile
        case 3: return .smile
        default: return .bigSmile
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Circle()
                .fill(faceColor)
                .frame(width: 44, height: 44)
                .scaleEffect(isSelected ? 1.08 : 1)

            VStack(spacing: -2) {
                LeafShape()
                    .fill(faceColor)
                    .frame(width: 13, height: 22)
                    .rotationEffect(.degrees(-34))
                    .offset(x: -5, y: 5)

                LeafShape()
                    .fill(faceColor)
                    .frame(width: 13, height: 24)
                    .rotationEffect(.degrees(32))
                    .offset(x: 8, y: -10)
            }
            .offset(y: -34)
            .opacity(score >= 2 ? 1 : 0.45)

            HStack(spacing: 7) {
                Circle().fill(.white.opacity(0.95)).frame(width: 6, height: 6)
                Circle().fill(.white.opacity(0.95)).frame(width: 6, height: 6)
            }
            .offset(y: -23)

            MouthShape(kind: mouth)
                .stroke(.white.opacity(0.95), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .frame(width: 18, height: 10)
                .offset(y: -10)
        }
        .frame(width: 50, height: 58)
    }
}

struct MouthShape: Shape {
    enum Kind {
        case frown, neutral, smallSmile, smile, bigSmile
    }

    let kind: Kind

    func path(in rect: CGRect) -> Path {
        var path = Path()

        switch kind {
        case .frown:
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY), control: CGPoint(x: rect.midX, y: rect.minY))
        case .neutral:
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        case .smallSmile:
            path.move(to: CGPoint(x: rect.minX, y: rect.midY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.midY), control: CGPoint(x: rect.midX, y: rect.maxY))
        case .smile:
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY), control: CGPoint(x: rect.midX, y: rect.maxY))
        case .bigSmile:
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.minY), control: CGPoint(x: rect.midX, y: rect.maxY + rect.height * 0.25))
        }

        return path
    }
}
