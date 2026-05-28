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
                    .foregroundStyle(Color(hex: "#A5A827"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .scaleEffect(1 - (progress * 0.03), anchor: .leading)

                Button(action: addAction) {
                    Image(systemName: "plus")
                        .font(.system(size: plusIconSize, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: plusSize, height: plusSize)
                        .background(Color(hex: "#A5A827"))
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
            .background(Color(hex: "#A5A827"))
            .clipShape(RoundedRectangle(cornerRadius: statCornerRadius, style: .continuous))
            .scaleEffect(1 - (progress * 0.015), anchor: .top)
            .shadow(color: .black.opacity(0.05 + (progress * 0.08)), radius: 14, y: 8)
        }
    }
}

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

struct CollectionScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
