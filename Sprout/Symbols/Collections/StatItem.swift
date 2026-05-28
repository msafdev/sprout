//
//  StatItem.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//
import SwiftUI
struct StatItem: View {
    let value: Int
    let title: String
    let progress: CGFloat

    init(value: Int, title: String, progress: CGFloat = 0) {
        self.value = value
        self.title = title
        self.progress = progress
    }

    var body: some View {
        VStack(spacing: 4 - (progress * 1.5)) {
            Text("\(value)")
                .font(.system(size: 22 - (progress * 4), weight: .black))
                .foregroundStyle(.white)

            Text(title)
                .font(.system(size: 13 - (progress * 1), weight: .medium))
                .foregroundStyle(.white.opacity(0.95))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}
