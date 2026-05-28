//
//  CollectionCard.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//
import SwiftUI
struct CollectionCard: View {
    let roadmap: Roadmap

    private var progressText: String {
        roadmap.hasEnoughMilestones ? "\(Int(roadmap.progress * 100))%" : "Need 5"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(roadmap.title)
                .font(.system(size: 15, weight: .black))
                .foregroundStyle(Color.fromHex(roadmap.colorHex))
                .lineLimit(1)

            Text("\(roadmap.milestones.count) Entries")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(.black.opacity(0.38))

            HStack(spacing: 8) {
                MiniProgressBar(progress: roadmap.progress, accent: Color.fromHex(roadmap.colorHex))
                    .frame(height: 5)

                Text(progressText)
                    .font(.system(size: 11, weight: .black))
                    .foregroundStyle(roadmap.hasEnoughMilestones ? Color.fromHex(roadmap.colorHex) : .black.opacity(0.35))
                    .frame(width: 42, alignment: .trailing)
            }
            .padding(.top, 8)

            Spacer(minLength: 0)

            SproutMascot(accent: roadmap.hasEnoughMilestones ? Color.fromHex(roadmap.colorHex) : Color.black.opacity(0.16))
                .frame(width: 108, height: 92)
                .frame(maxWidth: .infinity, alignment: .center)
                .offset(y: 18)
        }
        .padding(.top, 18)
        .padding(.horizontal, 14)
        .frame(height: 190)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 17, style: .continuous))
        .shadow(color: .black.opacity(0.13), radius: 12, x: 0, y: 7)
        .clipped()
    }
}
