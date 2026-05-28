//
//  MiniProgressBar.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//

import SwiftUI
struct MiniProgressBar: View {
    let progress: Double
    let accent: Color

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.black.opacity(0.08))

                Capsule()
                    .fill(accent)
                    .frame(width: proxy.size.width * progress)
            }
        }
        .frame(height: 5)
    }
}
