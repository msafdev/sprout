//
//  FeelingPicker.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//
import SwiftUI

struct FeelingPicker: View {
    @Binding var selectedScore: Int?
    let accent: Color

    var body: some View {
        HStack(spacing: 13) {
            ForEach(0..<5, id: \.self) { score in
                Button {
                    withAnimation(.snappy(duration: 0.22)) {
                        selectedScore = score
                    }
                } label: {
                    FeelingIcon(score: score, isSelected: selectedScore == score, accent: accent)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.035))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
