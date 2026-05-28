//
//  EyeView.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//

import SwiftUI
struct EyeView: View {
    var body: some View {
        Circle()
            .fill(.white)
            .frame(width: 13, height: 13)
            .overlay(alignment: .center) {
                Circle()
                    .fill(Color.black.opacity(0.45))
                    .frame(width: 5, height: 5)
            }
    }
}
