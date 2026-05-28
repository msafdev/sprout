//
//  PendingLessonRow.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//

import SwiftUI
struct PendingLessonRow: View {
    let number: Int
    let title: String
    let removeAction: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text(String(format: "%02d", number))
                .font(.system(size: 13, weight: .black))
                .foregroundStyle(Color.fromHex("#A5A827"))
                .frame(width: 38, height: 38)
                .background(Color.fromHex("#A5A827").opacity(0.11))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text(title)
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(.black)
                .lineLimit(2)

            Spacer(minLength: 8)

            Button(action: removeAction) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .black))
                    .foregroundStyle(.black.opacity(0.38))
                    .frame(width: 32, height: 32)
                    .background(Color.black.opacity(0.06))
                    .clipShape(Circle())
            }
        }
        .padding(12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
    }
}
