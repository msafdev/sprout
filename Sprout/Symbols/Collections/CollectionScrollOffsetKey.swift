//
//  CollectionScrollOffsetKey.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//

import SwiftUI
struct CollectionScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
