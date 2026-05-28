//
//  LeafShape.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//
import SwiftUI
struct LeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control1: CGPoint(x: rect.minX - rect.width * 0.15, y: rect.height * 0.62),
            control2: CGPoint(x: rect.minX, y: rect.height * 0.10)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control1: CGPoint(x: rect.maxX, y: rect.height * 0.10),
            control2: CGPoint(x: rect.maxX + rect.width * 0.15, y: rect.height * 0.62)
        )
        return path
    }
}
