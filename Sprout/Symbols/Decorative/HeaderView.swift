//
//  HeaderView.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//

import SwiftUI
struct HeaderView: View {
    let eyebrow: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "gearshape.2.fill")
                    .font(.system(size: 22, weight: .bold))
                Text(eyebrow)
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundStyle(Color.fromHex("#0F7897"))

            Text(title)
                .font(.system(size: 42, weight: .black))
                .foregroundStyle(.black)

            Text(subtitle)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.black.opacity(0.55))
                .lineSpacing(3)
        }
    }
}
