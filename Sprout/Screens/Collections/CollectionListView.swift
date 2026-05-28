//
//  CollectionListView.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//
import SwiftUI

struct CollectionListView: View {
    let roadmaps: [Roadmap]

    @State private var showingAddCollection = false
    @State private var scrollOffset: CGFloat = 0

    private let columns = [
        GridItem(.flexible(), spacing: 22),
        GridItem(.flexible(), spacing: 22)
    ]

    private var totalEntries: Int {
        roadmaps.reduce(0) { $0 + $1.milestones.count }
    }

    private var sproutedCount: Int {
        roadmaps.filter { $0.isFullySprouted }.count
    }

    private var collapseProgress: CGFloat {
        min(max(scrollOffset / 135, 0), 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CollapsibleCollectionHeader(
                collectionCount: roadmaps.count,
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
                    ForEach(roadmaps) { roadmap in
                        NavigationLink {
                            CollectionDetailView(roadmap: roadmap)
                        } label: {
                            CollectionCard(roadmap: roadmap)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .sheet(isPresented: $showingAddCollection) {
            AddCollectionView()
        }
    }
}
