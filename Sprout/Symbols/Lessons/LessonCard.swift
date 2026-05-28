//
//  LessonCard.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//
import SwiftUI
struct LessonCard: View {
    let index: Int
    let milestone: Milestone
    let accent: Color

    private var statusText: String {
        milestone.isCompletedForProgress ? "Completed" : "Incomplete"
    }

    private var statusIcon: String {
        milestone.isCompletedForProgress ? "checkmark.circle.fill" : "circle"
    }

    private var statusColor: Color {
        milestone.isCompletedForProgress ? accent : .black.opacity(0.34)
    }

    private var cardBackground: Color {
        milestone.isCompletedForProgress ? .white : .white.opacity(0.68)
    }

    private var tileBackground: Color {
        milestone.isCompletedForProgress ? accent.opacity(0.14) : .black.opacity(0.055)
    }

    private var tileTextColor: Color {
        milestone.isCompletedForProgress ? accent : .black.opacity(0.28)
    }

    private var borderColor: Color {
        milestone.isCompletedForProgress ? accent.opacity(0.24) : .black.opacity(0.035)
    }

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(tileBackground)
                    .frame(width: 72, height: 72)

                VStack(spacing: 2) {
                    Text(String(format: "%02d", index))
                        .font(.system(size: 18, weight: .black))
                    Text("LESSON")
                        .font(.system(size: 8, weight: .black))
                }
                .foregroundStyle(tileTextColor)
            }

            VStack(alignment: .leading, spacing: 7) {
                Text(milestone.title)
                    .font(.system(size: 18, weight: .black))
                    .foregroundStyle(.black.opacity(milestone.isCompletedForProgress ? 1 : 0.78))
                    .lineLimit(2)

                Text(milestone.hasExplanation ? milestone.explanation : "Tap to add explanation")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.black.opacity(milestone.hasExplanation ? 0.52 : 0.30))
                    .lineLimit(2)

                HStack(spacing: 7) {
                    LowKeyFeelingPreview(score: milestone.feelingScore)

                    Image(systemName: statusIcon)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(statusColor)

                    Text(statusText)
                        .font(.system(size: 12, weight: .black))
                        .foregroundStyle(statusColor)
                }
                .padding(.top, 2)
            }

            Spacer(minLength: 6)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.black.opacity(0.20))
        }
        .padding(14)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(borderColor, lineWidth: 1)
        }
        .shadow(color: .black.opacity(milestone.isCompletedForProgress ? 0.07 : 0.035), radius: 14, y: 8)
    }
}
