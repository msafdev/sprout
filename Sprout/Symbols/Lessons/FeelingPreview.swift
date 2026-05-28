//
//  FeelingPreview.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//

import SwiftUI

struct LowKeyFeelingPreview: View {
    let score: Int?

    private var symbolName: String {
        guard let score else { return "face.smiling" }

        switch score {
        case 0: return "face.dashed"
        case 1: return "face.smiling.inverse"
        case 2: return "face.smiling"
        case 3: return "face.smiling.fill"
        default: return "face.smiling.fill"
        }
    }

    private var iconOpacity: Double {
        score == nil ? 0.20 : 0.42
    }

    var body: some View {
        Image(systemName: symbolName)
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color.black.opacity(iconOpacity))
            .frame(width: 18, height: 18)
    }
}
