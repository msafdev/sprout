//
//  CollectionDetailTopBar.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//

import SwiftUI

struct CollectionDetailTopBar: View {
    let title: String
    let onBack: () -> Void
    let onAdd: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 54, height: 54)
                    .background(.white.opacity(0.9))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
            }

            Spacer()

            Text(title)
                .font(.system(size: 18, weight: .black))
                .foregroundStyle(.black.opacity(0.82))
                .lineLimit(1)

            Spacer()

            Button(action: onAdd) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 46, height: 46)
                    .background(Color.fromHex("#A5A827"))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.10), radius: 10, y: 5)
            }
        }
    }
}
