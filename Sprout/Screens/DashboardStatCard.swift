//
//  DashboardStatCard.swift
//  Sprout
//
//  Created by Gusti Sandyaga Putra Wardhana on 05/06/26.
//

import SwiftUI

// MARK: - Dashboard Stat Card
struct DashboardStatCard: View {
    @Environment(\.colorScheme) private var colorScheme

    let iconName: String
    let value: Int
    let label: String

    var scaleX: CGFloat
    var scaleY: CGFloat
    var offsetY: CGFloat

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .center, spacing: -8) {
                Text(label)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .lineLimit(2)
                Image(iconName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.white)
                    .scaleEffect(x: scaleX, y: scaleY)
                    .offset(y: offsetY)
            }
            Spacer()

            Text("\(value)")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.trailing)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, maxHeight: 80)
        .background(
            //            LinearGradient(
            //                colors: if colorScheme == .dark {
            //                    [Color.fromHex("#8F8E2C"), Color.fromHex("#C7C670")]
            //                } else {
            //                    [Color.fromHex("#BEC740"), Color.fromHex("#73741A")]
            //                },
            //                startPoint: .topLeading,
            //                endPoint: .bottomTrailing
            //            )

            LinearGradient(
                colors: colorScheme == .dark
                ? [Color.fromHex("#73741A"),
                   Color.fromHex("#BEC740")]
                : [Color.fromHex("#8F8E2C"),
                   Color.fromHex("#C7C670")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.25), lineWidth: 1.5)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
