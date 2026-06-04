//
//  PresentationHelpers.swift
//  Sprout
//
//  Created by Salman Alfarisi on 25/05/26.
//

import SwiftUI

extension Color {
    // Olive accent — brighter in dark mode for better contrast (#BEC740 dark / #9F9E32 light)
    static let appAccent = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 190/255, green: 199/255, blue: 64/255, alpha: 1)
            : UIColor(red: 159/255, green: 158/255, blue: 50/255, alpha: 1)
    })

    static let appBackground = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 20/255, green: 20/255, blue: 16/255, alpha: 1)
            : UIColor(red: 245/255, green: 245/255, blue: 236/255, alpha: 1)
    })

    static let appCard = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 30/255, green: 30/255, blue: 24/255, alpha: 1)
            : .white
    })

    // Warm-tinted primary text: near-black with olive hint in light, warm cream in dark
    static let appPrimary = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 238/255, green: 240/255, blue: 220/255, alpha: 1)
            : UIColor(red: 28/255, green: 28/255, blue: 20/255, alpha: 1)
    })

    // Muted warm secondary text
    static let appSecondary = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 154/255, green: 156/255, blue: 130/255, alpha: 1)
            : UIColor(red: 106/255, green: 106/255, blue: 90/255, alpha: 1)
    })
}

struct AppGradientBackground: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Group {
            if colorScheme == .dark {
                LinearGradient(
                    colors: [
                        Color(red: 22/255, green: 24/255, blue: 16/255),
                        Color(red: 18/255, green: 20/255, blue: 14/255),
                        Color(red: 14/255, green: 14/255, blue: 10/255)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            } else {
                LinearGradient(
                    colors: [
                        Color.fromHex("#EFEFD5"),
                        Color.fromHex("#FFFFF3"),
                        Color.white
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .ignoresSafeArea()
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(Color.appAccent.opacity(colorScheme == .dark ? 0.08 : 0.0))
                .frame(width: 230, height: 230)
                .blur(radius: 40)
                .offset(x: 80, y: -70)
        }
        .overlay(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 999, style: .continuous)
                .fill(colorScheme == .dark ? Color.white.opacity(0.03) : Color.white.opacity(0.34))
                .frame(width: 220, height: 70)
                .blur(radius: 10)
                .offset(x: -40, y: 92)
        }
    }
}

struct PresentationHelpers {
    static func detentForItemCount(_ count: Int) -> PresentationDetent {
        return count > 1 ? .fraction(0.81) : .fraction(0.70)
    }

    static func formattedDateOrdinal(_ date: Date, calendar: Calendar = .current) -> String {
        let day = calendar.component(.day, from: date)
        let suffix: String
        if (11...13).contains(day) {
            suffix = "th"
        } else {
            switch day % 10 {
            case 1: suffix = "st"
            case 2: suffix = "nd"
            case 3: suffix = "rd"
            default: suffix = "th"
            }
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        let monthAndDay = formatter.string(from: date)
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: date)
        return "\(monthAndDay)\(suffix), \(year)"
    }
}
