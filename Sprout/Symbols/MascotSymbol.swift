import SwiftUI

struct MascotSymbol: View {
    var size: CGFloat = 46
    var fillColor: Color = Color(red: 139/255, green: 165/255, blue: 67/255)
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Ellipse()
                .fill(fillColor)
                .frame(width: size, height: size * 1.08)
                .overlay(
                    VStack(spacing: 2) {
                        HStack(spacing: 6) {
                            Circle().fill(Color.black.opacity(0.8)).frame(width: 3, height: 3)
                            Circle().fill(Color.black.opacity(0.8)).frame(width: 3, height: 3)
                        }
                        Capsule()
                            .stroke(Color.black.opacity(0.8), lineWidth: 1.5)
                            .frame(width: 6, height: 2)
                    }
                    .offset(y: 4)
                )
            
            Image(systemName: "leaf.fill")
                .font(.system(size: 16))
                .foregroundColor(fillColor)
                .rotationEffect(.degrees(-35))
                .offset(x: 2, y: -16)
        }
        .shadow(color: Color.black.opacity(0.1), radius: 3)
    }
}

struct MascotSymbol_Previews: PreviewProvider {
    static var previews: some View {
        MascotSymbol()
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
