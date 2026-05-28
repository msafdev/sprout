//
//  FeelingIcon.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//

import SwiftUI

struct FeelingIcon: View {
    let score: Int
    let isSelected: Bool
    let accent: Color

    private var faceColor: Color {
        isSelected ? accent : Color.black.opacity(0.18)
    }

    private var mouth: String {
        switch score {
        case 0: return "frown"
        case 1: return "neutral"
        case 2: return "smallSmile"
        case 3: return "smile"
        default: return "bigSmile"
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
                Circle()
                    .fill(.white.opacity(0.95))
                    .frame(width: 6, height: 6)
                Circle()
                    .fill(.white.opacity(0.95))
                    .frame(width: 6, height: 6)
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
