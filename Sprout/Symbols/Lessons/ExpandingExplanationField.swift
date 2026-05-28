//
//  ExpandingExplanationField.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//
import SwiftUI
struct ExpandingExplanationField: View {
    @Binding var text: String

    var body: some View {
        TextField("Write the lesson explanation here...", text: $text, axis: .vertical)
            .font(.system(size: 17, weight: .regular))
            .foregroundStyle(.black.opacity(0.82))
            .lineLimit(6...)
            .textFieldStyle(.plain)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(Color.black.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
