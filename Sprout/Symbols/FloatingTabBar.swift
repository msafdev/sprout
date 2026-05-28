//
//  FloatingTabBar.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//

import SwiftUI
import SwiftData
struct FloatingTabBar: View {
    @Binding var selectedTab: AppTab
    let cameraAction: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            TabBarNotchedShape(
                notchWidth: 114,
                notchDepth: 55,
                cornerRadius: 30
            )
            .fill(.white.opacity(0.97))
            .frame(height: 74)
            .shadow(color: .black.opacity(0.12), radius: 18, y: 8)
            .padding(.top, 32)

            HStack(spacing: 0) {
                TabButton(tab: .recollection, selectedTab: $selectedTab)
                Spacer(minLength: 86)
                TabButton(tab: .collection, selectedTab: $selectedTab)
            }
            .padding(.horizontal, 22)
            .padding(.top, 30)
            .frame(height: 106)

            Button(action: cameraAction) {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 66, height: 66)
                        .shadow(color: .black.opacity(0.14), radius: 12, y: 6)

                    Circle()
                        .stroke(.black.opacity(0.06), lineWidth: 1)
                        .frame(width: 66, height: 66)

                    Image(systemName: "camera")
                        .font(.system(size: 23, weight: .bold))
                        .foregroundStyle(.black.opacity(0.38))
                }
            }
            .offset(y: 14)
        }
        .frame(height: 112)
    }
}

struct TabBarNotchedShape: Shape {
    var notchWidth: CGFloat
    var notchDepth: CGFloat
    var cornerRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let radius = min(cornerRadius, height / 2)

        let centerX = width / 2
        let notchHalfWidth = notchWidth / 2
        let notchStartX = centerX - notchHalfWidth
        let notchEndX = centerX + notchHalfWidth

        var path = Path()

        path.move(to: CGPoint(x: radius, y: 0))
        path.addLine(to: CGPoint(x: notchStartX, y: 0))

        path.addCurve(
            to: CGPoint(x: centerX, y: notchDepth),
            control1: CGPoint(x: notchStartX + 20, y: 0),
            control2: CGPoint(x: centerX - 34, y: notchDepth)
        )

        path.addCurve(
            to: CGPoint(x: notchEndX, y: 0),
            control1: CGPoint(x: centerX + 34, y: notchDepth),
            control2: CGPoint(x: notchEndX - 20, y: 0)
        )

        path.addLine(to: CGPoint(x: width - radius, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: width, y: radius),
            control: CGPoint(x: width, y: 0)
        )

        path.addLine(to: CGPoint(x: width, y: height - radius))
        path.addQuadCurve(
            to: CGPoint(x: width - radius, y: height),
            control: CGPoint(x: width, y: height)
        )

        path.addLine(to: CGPoint(x: radius, y: height))
        path.addQuadCurve(
            to: CGPoint(x: 0, y: height - radius),
            control: CGPoint(x: 0, y: height)
        )

        path.addLine(to: CGPoint(x: 0, y: radius))
        path.addQuadCurve(
            to: CGPoint(x: radius, y: 0),
            control: CGPoint(x: 0, y: 0)
        )

        path.closeSubpath()
        return path
    }
}

struct TabButton: View {
    let tab: AppTab
    @Binding var selectedTab: AppTab

    var isSelected: Bool { selectedTab == tab }

    var body: some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 19, weight: .bold))

                Text(tab.title)
                    .font(.system(size: 10, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(isSelected ? Color.fromHex("#A5A827") : .black.opacity(0.28))
        }
    }
}

#Preview {
    RootView()
        .modelContainer(for: [Roadmap.self, Milestone.self], inMemory: true)
}
