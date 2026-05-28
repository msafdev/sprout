//
//  CollectionDetailView.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//
import SwiftUI
import SwiftData
struct CollectionDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var roadmap: Roadmap
    @State private var showingAddLesson = false
    @State private var showingEditCollection = false
    @State private var showingDeleteAlert = false

    var body: some View {
        ZStack {
            SkyLearningBackground()

            VStack(spacing: 0) {
                CollectionDetailTopBar(
                    title: roadmap.title,
                    onBack: { dismiss() },
                    onAdd: { showingAddLesson = true }
                )
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 14)
                .background(
                    SkyLearningHeaderBackground()
                        .opacity(0.97)
                        .ignoresSafeArea(edges: .top)
                )
                .shadow(color: .black.opacity(0.035), radius: 10, y: 5)
                .zIndex(10)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("\(roadmap.milestones.count) Entries")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.black.opacity(0.45))

                            Text(roadmap.title)
                                .font(.system(size: 34, weight: .black))
                                .foregroundStyle(.black)

                            Text(roadmap.goalDescription)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.black.opacity(0.55))
                                .lineSpacing(3)
                        }
                        .padding(.horizontal, 4)

                        CollectionProgressCard(
                            roadmap: roadmap,
                            accent: Color.fromHex(roadmap.colorHex)
                        )

                        VStack(spacing: 14) {
                            ForEach(roadmap.sortedMilestones) { milestone in
                                NavigationLink {
                                    LessonDetailView(milestone: milestone, accent: Color.fromHex(roadmap.colorHex))
                                } label: {
                                    LessonCard(
                                        index: milestone.orderIndex + 1,
                                        milestone: milestone,
                                        accent: Color.fromHex(roadmap.colorHex)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Text("Delete Collection")
                                .font(.system(size: 15, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(.white.opacity(0.9))
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .safeAreaPadding(.bottom, 28)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingAddLesson) {
            AddLessonView(roadmap: roadmap)
        }
        .sheet(isPresented: $showingEditCollection) {
            EditCollectionView(roadmap: roadmap)
        }
        .alert("Delete collection?", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                modelContext.delete(roadmap)
                dismiss()
            }
        } message: {
            Text("All lessons inside this collection will also be deleted.")
        }
    }
}



struct DetailTopBar: View {
    let title: String
    let onBack: () -> Void
    let onEdit: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.9))
                    .clipShape(Circle())
            }

            Spacer()

            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.black.opacity(0.7))

            Spacer()

            Button(action: onEdit) {
                Image(systemName: "checkmark")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.fromHex("#A5A827"))
                    .frame(width: 42, height: 42)
                    .background(.white.opacity(0.9))
                    .clipShape(Circle())
            }
        }
    }
}
