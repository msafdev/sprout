//
//  CollapsibleCollectionHeader.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//

import SwiftUI
struct CollapsibleCollectionHeader: View {
    let collectionCount: Int
    let entryCount: Int
    let sproutedCount: Int
    let progress: CGFloat
    let addAction: () -> Void

    private var titleSize: CGFloat { 42 - (progress * 15) }
    private var plusSize: CGFloat { 48 - (progress * 12) }
    private var plusIconSize: CGFloat { 22 - (progress * 4) }
    private var statsVerticalPadding: CGFloat { 18 - (progress * 11) }
    private var spacing: CGFloat { 28 - (progress * 17) }
    private var statCornerRadius: CGFloat { 24 - (progress * 8) }

    var body: some View {
        VStack(spacing: spacing) {
            HStack(alignment: .center) {
                Text("Collections")
                    .font(.system(size: titleSize, weight: .black))
                    .foregroundStyle(Color.fromHex("#A5A827"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaleEffect(1 - (progress * 0.03), anchor: .leading)

                Button(action: addAction) {
                    Image(systemName: "plus")
                        .font(.system(size: plusIconSize, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: plusSize, height: plusSize)
                        .background(Color.fromHex("#A5A827"))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.14), radius: 12, y: 7)
                }
            }

            HStack(spacing: 0) {
                StatItem(value: collectionCount, title: "Collection", progress: progress)
                StatItem(value: entryCount, title: "Entries", progress: progress)
                StatItem(value: sproutedCount, title: "Sprouted", progress: progress)
            }
            .padding(.vertical, statsVerticalPadding)
            .background(Color.fromHex("#A5A827"))
            .clipShape(RoundedRectangle(cornerRadius: statCornerRadius, style: .continuous))
            .scaleEffect(1 - (progress * 0.015), anchor: .top)
            .shadow(color: .black.opacity(0.05 + (progress * 0.08)), radius: 14, y: 8)
        }
    }
}

#Preview {
    CollapsibleCollectionHeader(collectionCount: 3, entryCount: 3, sproutedCount: 3, progress: 0.8, addAction: {
        print("addAction successfully tapped in preview! 🎉")
    })
}
