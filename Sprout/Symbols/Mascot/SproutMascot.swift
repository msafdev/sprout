//
//  SproutMascot.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//

import SwiftUI
struct SproutMascot: View {
    let accent: Color

    var body: some View {
        ZStack(alignment: .bottom) {
            Circle()
                .fill(accent)
                .frame(width: 86, height: 86)
                .offset(y: 30)

            HStack(spacing: 12) {
                EyeView()
                EyeView()
            }
            .offset(y: 4)

            Capsule()
                .fill(.white)
                .frame(width: 8, height: 28)
                .offset(x: 31, y: 17)

            VStack(spacing: -2) {
                LeafShape()
                    .fill(accent)
                    .frame(width: 22, height: 38)
                    .rotationEffect(.degrees(-34))
                    .offset(x: -8, y: 8)

                LeafShape()
                    .fill(accent)
                    .frame(width: 22, height: 42)
                    .rotationEffect(.degrees(32))
                    .offset(x: 14, y: -16)
            }
            .offset(y: -48)
        }
    }
}
