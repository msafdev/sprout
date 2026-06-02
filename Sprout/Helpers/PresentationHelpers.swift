//
//  PresentationHelpers.swift
//  Sprout
//
//  Created by Salman Alfarisi on 25/05/26.
//

import SwiftUI

extension Color {
    static let appAccent = Color(red: 159/255, green: 158/255, blue: 50/255)
    static let appBackground = Color(red: 245/255, green: 245/255, blue: 236/255)
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
