//
//  CollectionProgressCard.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//
import SwiftUI


struct CollectionProgressCard: View {
    let roadmap: Roadmap
    let accent: Color

    private var titleText: String {
        if !roadmap.hasEnoughMilestones { return "Not Enough Lessons" }
        return roadmap.progress >= 1 ? "Fully Sprouted" : "Sprout"
    }

    private var subtitleText: String {
        if !roadmap.hasEnoughMilestones {
            return "Add \(roadmap.remainingMilestonesNeeded) more lesson\(roadmap.remainingMilestonesNeeded == 1 ? "" : "s") to activate progress"
        }

        if roadmap.progress >= 1 {
            return "Collection complete"
        }

        return "\(roadmap.remainingMilestonesToComplete) of \(roadmap.milestones.count) lessons left"
    }

    private var percentText: String {
        roadmap.hasEnoughMilestones ? "\(Int(roadmap.progress * 100))%" : "Invalid"
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 7) {
                Text(titleText)
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(roadmap.hasEnoughMilestones ? accent : .black.opacity(0.38))

                Text(subtitleText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.black.opacity(0.38))
                    .lineLimit(2)

                HStack(spacing: 10) {
                    MiniProgressBar(progress: roadmap.progress, accent: roadmap.hasEnoughMilestones ? accent : Color.black.opacity(0.18))
                        .frame(height: 6)

                    Text(percentText)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(roadmap.hasEnoughMilestones ? .black.opacity(0.32) : .black.opacity(0.28))
                }
                .padding(.top, 4)
            }

            Spacer(minLength: 6)

            SproutMascot(accent: roadmap.hasEnoughMilestones ? accent : Color.black.opacity(0.16))
                .frame(width: 70, height: 54)
                .offset(y: 12)
        }
        .padding(.horizontal, 22)
        .frame(height: 118)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.10), radius: 14, y: 8)
        .clipped()
    }
}
