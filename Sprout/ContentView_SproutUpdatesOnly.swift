import SwiftUI
import SwiftData
import PhotosUI
import UIKit


// Update your <ProjectName>App.swift to:
// WindowGroup { RootView() }
// .modelContainer(for: [Roadmap.self, Milestone.self])

// MARK: - Root

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Roadmap.createdAt, order: .reverse) private var roadmaps: [Roadmap]

    @State private var selectedTab: AppTab = .collection
    @State private var showingCameraPlaceholder = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                SkyLearningBackground()

                Group {
                    switch selectedTab {
                    case .recollection:
                        RecollectionView()
                    case .collection:
                        CollectionListView(roadmaps: roadmaps)
                    }
                }
                .safeAreaPadding(.bottom, 92)

                FloatingTabBar(selectedTab: $selectedTab) {
                    showingCameraPlaceholder = true
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 0)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingCameraPlaceholder) {
                CameraPlaceholderView()
                    .presentationDetents([.medium])
            }
            .onAppear {
                seedExampleDataIfNeeded()
            }
        }
    }

    private func seedExampleDataIfNeeded() {
        guard roadmaps.isEmpty else { return }

        let machining = Roadmap(
            title: "Machining Fundamentals",
            goalDescription: "A beginner-friendly roadmap for cutting tools, tool geometry, and machining principles.",
            colorHex: "#A5A827"
        )

        machining.milestones = [
            Milestone(
                title: "Cutting Tool Components",
                explanation: "Most cutting tools, such as planers, drills, and milling cutters, can be understood as variations or combinations of a single-point turning tool.\n\nA planer tool has a cutting section similar to a turning tool.\n\nA milling cutter can be viewed as a compound tool made from multiple cutting edges working together.\n\nA drill can be understood as two opposite cutting edges that remove material from the wall of a hole at the same time.",
                feelingScore: 3,
                orderIndex: 0,
                roadmap: machining
            ),
            Milestone(
                title: "Cutting Motion Direction",
                explanation: "This lesson explains the direction of the main cutting motion and the feed motion during a machining process. Use the photo area as a visual reference for the movement of the workpiece and tool.",
                feelingScore: 2,
                orderIndex: 1,
                roadmap: machining
            ),
            Milestone(
                title: "Tool Body and Cutting Edge",
                explanation: "Learn how the tool body, main cutting edge, and auxiliary cutting edge work together. You can edit this lesson later and replace it with your own study material.",
                feelingScore: nil,
                orderIndex: 2,
                roadmap: machining
            )
        ]

        modelContext.insert(machining)
    }
}

// MARK: - App Tab

enum AppTab {
    case recollection
    case collection

    var title: String {
        switch self {
        case .recollection: return "Recollection"
        case .collection: return "Collection"
        }
    }

    var icon: String {
        switch self {
        case .recollection: return "rectangle.grid.2x2"
        case .collection: return "square.stack.3d.up"
        }
    }
}

// MARK: - Collection List




struct CollectionStatsBar: View {
    let collectionCount: Int
    let entryCount: Int
    let sproutedCount: Int

    var body: some View {
        HStack(spacing: 0) {
            StatItem(value: collectionCount, title: "Collection")
            StatItem(value: entryCount, title: "Entries")
            StatItem(value: sproutedCount, title: "Sprouted")
        }
        .padding(.vertical, 14)
        .background(Color.fromHex("#A5A827"))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
    }
}


struct RecollectionView: View {
    var body: some View {
        Text("go implement")
    }
}

struct CameraPlaceholderView: View {
    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.fromHex("#A5A827").opacity(0.14))
                    .frame(width: 84, height: 84)

                Image(systemName: "camera")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Color.fromHex("#A5A827"))
            }

            Text("Camera Placeholder")
                .font(.system(size: 23, weight: .black))

            Text("Assets and scan/photo features are intentionally ignored for now. Later, this section can be connected to image import, camera capture, or OCR.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.black.opacity(0.55))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 30)
        }
    }
}

#Preview {
    // Create a single shared preview container explicitly
    let schema = Schema([Roadmap.self, Milestone.self])
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    
    return RootView()
        .modelContainer(container)
        // Explicitly inject the context into the environment as well to satisfy aggressive subview lifecycles
        .environment(\.modelContext, container.mainContext)
}
