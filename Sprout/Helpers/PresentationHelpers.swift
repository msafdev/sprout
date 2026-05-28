//
//  PresentationHelpers.swift
//  Sprout
//
//  Created by Salman Alfarisi on 25/05/26.
//

import SwiftUI

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
