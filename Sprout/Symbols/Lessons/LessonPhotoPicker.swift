//
//  LessonPhotoPicker.swift
//  Sprout
//
//  Created by Alex on 28/05/26.
//
import SwiftUI
import PhotosUI

struct LessonPhotoPicker: View {
    let photoData: Data?
    let accent: Color
    @Binding var selectedPhotoItem: PhotosPickerItem?
    let removeAction: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                ZStack {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.black.opacity(0.06))
                        .frame(height: 190)

                    if let photoData,
                       let image = UIImage(data: photoData) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 190)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    } else {
                        VStack(spacing: 10) {
                            Image(systemName: "plus")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 70, height: 70)
                                .background(accent)
                                .clipShape(Circle())

                            Text("Add Photo")
                                .font(.system(size: 15, weight: .black))
                                .foregroundStyle(.black.opacity(0.45))
                        }
                    }
                }
            }
            .buttonStyle(.plain)

            if photoData != nil {
                Button(role: .destructive, action: removeAction) {
                    Text("Remove Photo")
                        .font(.system(size: 13, weight: .bold))
                }
            }
        }
    }
}
