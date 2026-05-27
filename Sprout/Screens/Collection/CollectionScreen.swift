import SwiftUI
import SwiftData

/// Main collection list. Plug into `MainTabView` as a tab case.
struct CollectionScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LearningCollection.createdAt, order: .reverse) private var collections: [LearningCollection]

    @State private var showingAddCollection = false
    @State private var scrollOffset: CGFloat = 0

    private let columns = [
        GridItem(.flexible(), spacing: 22),
        GridItem(.flexible(), spacing: 22)
    ]

    private var totalEntries: Int {
        collections.reduce(0) { $0 + $1.lessons.count }
    }

    private var sproutedCount: Int {
        collections.filter(\.isFullySprouted).count
    }

    private var collapseProgress: CGFloat {
        min(max(scrollOffset / 135, 0), 1)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                SkyLearningBackground()

                VStack(alignment: .leading, spacing: 0) {
                    CollapsibleCollectionHeader(
                        collectionCount: collections.count,
                        entryCount: totalEntries,
                        sproutedCount: sproutedCount,
                        progress: collapseProgress
                    ) {
                        showingAddCollection = true
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 28 - (collapseProgress * 12))
                    .padding(.bottom, 18 - (collapseProgress * 10))
                    .background(
                        SkyLearningHeaderBackground()
                            .opacity(0.97)
                            .ignoresSafeArea(edges: .top)
                    )
                    .shadow(color: .black.opacity(collapseProgress * 0.08), radius: 14, y: 8)
                    .animation(.snappy(duration: 0.28), value: collapseProgress)
                    .zIndex(10)

                    ScrollView(showsIndicators: false) {
                        Color.clear
                            .frame(height: 1)
                            .background(
                                GeometryReader { proxy in
                                    Color.clear.preference(
                                        key: CollectionScrollOffsetKey.self,
                                        value: max(0, -proxy.frame(in: .named("collectionScrollArea")).minY)
                                    )
                                }
                            )

                        LazyVGrid(columns: columns, spacing: 26) {
                            ForEach(collections) { collection in
                                NavigationLink {
                                    CollectionDetailView(collection: collection)
                                } label: {
                                    CollectionCard(collection: collection)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 22)
                        .padding(.top, 20)
                        .padding(.bottom, 34)
                    }
                    .coordinateSpace(name: "collectionScrollArea")
                    .onPreferenceChange(CollectionScrollOffsetKey.self) { value in
                        scrollOffset = value
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingAddCollection) {
                AddCollectionView()
            }
            .onAppear(perform: seedExampleDataIfNeeded)
        }
    }

    private func seedExampleDataIfNeeded() {
        guard collections.isEmpty else { return }

        let machining = LearningCollection(
            title: "Machining Fundamentals",
            summary: "A beginner-friendly roadmap for cutting tools, tool geometry, and machining principles.",
            accentHex: "#A5A827"
        )

        machining.lessons = [
            Lesson(
                title: "Cutting Tool Components",
                explanation: "Most cutting tools, such as planers, drills, and milling cutters, can be understood as variations or combinations of a single-point turning tool.",
                feelingScore: 3,
                orderIndex: 0,
                collection: machining
            ),
            Lesson(
                title: "Cutting Motion Direction",
                explanation: "This lesson explains the direction of the main cutting motion and the feed motion during a machining process. Use the photo area as a visual reference for the movement of the workpiece and tool.",
                feelingScore: 2,
                orderIndex: 1,
                collection: machining
            ),
            Lesson(
                title: "Tool Body and Cutting Edge",
                explanation: "Learn how the tool body, main cutting edge, and auxiliary cutting edge work together. You can edit this lesson later and replace it with your own study material.",
                feelingScore: nil,
                orderIndex: 2,
                collection: machining
            )
        ]

        modelContext.insert(machining)
    }
}

#Preview {
    CollectionScreen()
        .modelContainer(for: [LearningCollection.self, Lesson.self], inMemory: true)
}

// MARK: - Reference: original in-page floating tab bar
//
// Preserved for reference only. The Collection page used to embed its own
// notched floating tab bar with a raised center camera button (lived inside
// the dead `RootView`). It's now superseded by `CustomTabBar` rendered from
// `MainTabView`. To re-enable, uncomment and wire `FloatingTabBar` into
// `MainTabView` (or overlay it inside `CollectionScreen.body`).
//
// private enum AppTab {
//     case recollection
//     case collection
//
//     var title: String {
//         switch self {
//         case .recollection: return "Recollection"
//         case .collection:   return "Collection"
//         }
//     }
//
//     var icon: String {
//         switch self {
//         case .recollection: return "rectangle.grid.2x2"
//         case .collection:   return "square.stack.3d.up"
//         }
//     }
// }
//
// private struct FloatingTabBar: View {
//     @Binding var selectedTab: AppTab
//     let cameraAction: () -> Void
//
//     var body: some View {
//         ZStack(alignment: .top) {
//             TabBarNotchedShape(notchWidth: 104, notchDepth: 40, cornerRadius: 30)
//                 .fill(.white.opacity(0.97))
//                 .frame(height: 74)
//                 .shadow(color: .black.opacity(0.12), radius: 18, y: 8)
//                 .padding(.top, 32)
//
//             HStack(spacing: 0) {
//                 TabButton(tab: .recollection, selectedTab: $selectedTab)
//                 Spacer(minLength: 86)
//                 TabButton(tab: .collection, selectedTab: $selectedTab)
//             }
//             .padding(.horizontal, 22)
//             .padding(.top, 50)
//             .frame(height: 106)
//
//             Button(action: cameraAction) {
//                 ZStack {
//                     Circle()
//                         .fill(.white)
//                         .frame(width: 66, height: 66)
//                         .shadow(color: .black.opacity(0.14), radius: 12, y: 6)
//
//                     Circle()
//                         .stroke(.black.opacity(0.06), lineWidth: 1)
//                         .frame(width: 66, height: 66)
//
//                     Image(systemName: "camera")
//                         .font(.system(size: 23, weight: .bold))
//                         .foregroundStyle(.black.opacity(0.38))
//                 }
//             }
//             .offset(y: 14)
//         }
//         .frame(height: 112)
//     }
// }
//
// private struct TabBarNotchedShape: Shape {
//     var notchWidth: CGFloat
//     var notchDepth: CGFloat
//     var cornerRadius: CGFloat
//
//     func path(in rect: CGRect) -> Path {
//         let width = rect.width
//         let height = rect.height
//         let radius = min(cornerRadius, height / 2)
//
//         let centerX = width / 2
//         let notchHalfWidth = notchWidth / 2
//         let notchStartX = centerX - notchHalfWidth
//         let notchEndX = centerX + notchHalfWidth
//
//         var path = Path()
//
//         path.move(to: CGPoint(x: radius, y: 0))
//         path.addLine(to: CGPoint(x: notchStartX, y: 0))
//
//         path.addCurve(
//             to: CGPoint(x: centerX, y: notchDepth),
//             control1: CGPoint(x: notchStartX + 20, y: 0),
//             control2: CGPoint(x: centerX - 34, y: notchDepth)
//         )
//
//         path.addCurve(
//             to: CGPoint(x: notchEndX, y: 0),
//             control1: CGPoint(x: centerX + 34, y: notchDepth),
//             control2: CGPoint(x: notchEndX - 20, y: 0)
//         )
//
//         path.addLine(to: CGPoint(x: width - radius, y: 0))
//         path.addQuadCurve(
//             to: CGPoint(x: width, y: radius),
//             control: CGPoint(x: width, y: 0)
//         )
//
//         path.addLine(to: CGPoint(x: width, y: height - radius))
//         path.addQuadCurve(
//             to: CGPoint(x: width - radius, y: height),
//             control: CGPoint(x: width, y: height)
//         )
//
//         path.addLine(to: CGPoint(x: radius, y: height))
//         path.addQuadCurve(
//             to: CGPoint(x: 0, y: height - radius),
//             control: CGPoint(x: 0, y: height)
//         )
//
//         path.addLine(to: CGPoint(x: 0, y: radius))
//         path.addQuadCurve(
//             to: CGPoint(x: radius, y: 0),
//             control: CGPoint(x: 0, y: 0)
//         )
//
//         path.closeSubpath()
//         return path
//     }
// }
//
// private struct TabButton: View {
//     let tab: AppTab
//     @Binding var selectedTab: AppTab
//
//     var isSelected: Bool { selectedTab == tab }
//
//     var body: some View {
//         Button {
//             selectedTab = tab
//         } label: {
//             VStack(spacing: 4) {
//                 Image(systemName: tab.icon)
//                     .font(.system(size: 19, weight: .bold))
//
//                 Text(tab.title)
//                     .font(.system(size: 10, weight: .bold))
//             }
//             .frame(maxWidth: .infinity)
//             .foregroundStyle(isSelected ? Color(hex: "#A5A827") : .black.opacity(0.28))
//         }
//     }
// }
