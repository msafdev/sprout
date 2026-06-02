//
//  RecollectScreen.swift
//  Sprout
//
//  Created by Salman Alfarisi on 25/05/26.
//

import SwiftUI
import SwiftData

struct RecollectScreen: View {
    @Query(sort: \Milestone.createdAt, order: .reverse) private var milestones: [Milestone]
    @State private var showingProfileSheet = false
    @State private var selectedDaySelection: DaySelection? = nil
    
    private var completedMilestones: [Milestone] {
        milestones
            .filter { $0.isCompleted && $0.completedAt != nil }
            .sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
    }
    
    var weekCount: Int {
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return completedMilestones.filter { milestone in
            guard let completedAt = milestone.completedAt else { return false }
            return completedAt >= oneWeekAgo
        }.count
    }
    
    var monthCount: Int {
        let calendar = Calendar.current
        let oneMonthAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return completedMilestones.filter { milestone in
            guard let completedAt = milestone.completedAt else { return false }
            return completedAt >= oneMonthAgo
        }.count
    }
    
    @State private var currentMonthDate: Date = Date()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 48) {
                VStack(alignment: .leading, spacing: 24) {
                    HStack {
                        Text("Collection")
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundColor(.primary)
                            .kerning(-0.5)
                        
                        Spacer()
                        
                        Button(action: { showingProfileSheet = true }) {
                            ZStack {
                                Circle()
                                    .fill(Color(.systemGray6))
                                    .frame(width: 44, height: 44)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.primary.opacity(0.7))
                            }
                        }
                    }
                    .padding(.top, 10)
                    
                    HStack(spacing: 12) {
                        // Card 1: This week
                        VStack(alignment: .leading, spacing: 36) {
                            HStack(alignment: .top) {
                                Image(systemName: "drop.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 28, height: 28)
                                    .background(Color.black.opacity(0.12))
                                    .clipShape(Circle())
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("This week")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text("\(weekCount) done")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.85))
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 70/255, green: 70/255, blue: 180/255))
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        
                        // Card 2: This month
                        VStack(alignment: .leading, spacing: 36) {
                            HStack(alignment: .top) {
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 28, height: 28)
                                    .background(Color.black.opacity(0.12))
                                    .clipShape(Circle())
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("This month")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text("\(monthCount) done")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.85))
                            }
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 150/255, green: 180/255, blue: 80/255))
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    }
                }
                
                VStack(spacing: 32) {
                    MonthCalendarView(monthDate: $currentMonthDate, milestones: completedMilestones) { dayMilestones in
                        if !dayMilestones.isEmpty {
                            selectedDaySelection = DaySelection(date: dayMilestones.first?.completedAt ?? Date(), milestones: dayMilestones)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 18) {
                        Text("History")
                            .font(.system(size: 22, weight: .bold))
                            .padding(.top, 8)
                        
                        if completedMilestones.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "tray")
                                    .font(.system(size: 32))
                                    .foregroundColor(.gray.opacity(0.5))
                                Text("No history yet")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                                Text("Your completed lessons and milestones will appear here")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                            .padding(.horizontal, 24)
                            .background(Color(.systemGray6).opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        } else {
                            ForEach(completedMilestones) { milestone in
                                HistoryRowView(milestone: milestone)
                            }
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(.systemBackground))
        .fullScreenCover(isPresented: $showingProfileSheet) {
            ProfileSheetView()
        }
        .sheet(item: $selectedDaySelection) { selection in
            RecollectDetailSheet(date: selection.date, allMilestones: completedMilestones)
        }
    }
}

struct DaySelection: Identifiable {
    let id = UUID()
    let date: Date
    let milestones: [Milestone]
}

struct HistoryRowView: View {
    let milestone: Milestone
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 48, height: 48)
                Image(systemName: "text.book.closed")
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(milestone.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                if let completedAt = milestone.completedAt {
                    Text(PresentationHelpers.formattedDateOrdinal(completedAt))
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(red: 150/255, green: 180/255, blue: 80/255))
                        .frame(width: 8, height: 8)
                    Text("Finished")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Image(systemName: "paperclip")
                .foregroundColor(.gray)
                .padding(12)
                .background(Color.gray.opacity(0.1))
                .clipShape(Circle())
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct ProfileSheetView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Text("Your Family")
                    .font(.system(size: 18, weight: .semibold))
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            ScrollView {
                VStack(spacing: 32) {
                    // Profile section
                    VStack(spacing: 0) {
                        SettingsRowView(
                            icon: "cloud.fill", iconColor: Color(red: 255/255, green: 75/255, blue: 114/255), isLargeIcon: true,
                            title: "Salman", subtitle: "Manage your account",
                            rightIcon: "chevron.right", rightText: nil
                        )
                        SettingsRowView(
                            icon: "person.crop.rectangle", iconColor: .gray.opacity(0.8), isLargeIcon: true,
                            title: "Address Book", subtitle: "Manage contacts & addresses",
                            rightIcon: "chevron.right", rightText: nil
                        )
                    }
                    .padding(.top, 16)
                    
                    // Settings Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SETTINGS")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.leading, 24)
                        
                        VStack(spacing: 0) {
                            SettingsRowView(icon: "dollarsign", iconColor: .gray, isLargeIcon: false, title: "Currency", rightIcon: "ellipsis", rightText: "USD")
                            SettingsRowView(icon: "moon", iconColor: .gray, isLargeIcon: false, title: "Appearance", rightIcon: "ellipsis", rightText: "Light")
                            SettingsRowView(icon: "wallet.pass", iconColor: .gray, isLargeIcon: false, title: "Manage Wallets", rightIcon: "chevron.right", rightText: nil)
                            SettingsRowView(icon: "slider.horizontal.3", iconColor: .gray, isLargeIcon: false, title: "Preferences", rightIcon: "chevron.right", rightText: nil)
                            SettingsRowView(icon: "safari", iconColor: .gray, isLargeIcon: false, title: "Browser Settings", rightIcon: "chevron.right", rightText: nil)
                            SettingsRowView(icon: "bell", iconColor: .gray, isLargeIcon: false, title: "Notifications", rightIcon: "ellipsis", rightText: nil)
                            SettingsRowView(icon: "bolt", iconColor: .gray, isLargeIcon: false, title: "Refuel Wallet", rightIcon: "ellipsis", rightText: nil)
                            SettingsRowView(icon: "app.dashed", iconColor: .gray, isLargeIcon: false, title: "App Icon", rightIcon: "ellipsis", rightText: nil)
                        }
                    }
                    
                    // More Options Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("MORE OPTIONS")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                            .padding(.leading, 24)
                        
                        VStack(spacing: 0) {
                            SettingsRowView(icon: "cloud", iconColor: .gray, isLargeIcon: false, title: "iCloud Backups", rightIcon: "chevron.right", rightText: nil)
                        }
                    }
                }
                .padding(.bottom, 40)
            }
        }
        .background(Color(.systemBackground))
    }
}

struct SettingsRowView: View {
    let icon: String
    let iconColor: Color
    let isLargeIcon: Bool
    let title: String
    var subtitle: String? = nil
    let rightIcon: String
    let rightText: String?
    
    var body: some View {
        HStack(spacing: 16) {
            if isLargeIcon {
                if icon == "cloud.fill" {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)
                        .background(iconColor)
                        .clipShape(Circle())
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 32, weight: .light))
                        .foregroundColor(iconColor)
                        .frame(width: 48, height: 48)
                }
            } else {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(iconColor)
                    .frame(width: 32, height: 32)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.primary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            if let rightText = rightText {
                Text(rightText)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            if rightIcon == "ellipsis" {
                Image(systemName: rightIcon)
                    .rotationEffect(.degrees(90))
                    .font(.system(size: 18))
                    .foregroundColor(.gray.opacity(0.8))
            } else {
                Image(systemName: rightIcon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray.opacity(0.6))
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, isLargeIcon ? 16 : 14)
        .contentShape(Rectangle())
    }
}

struct MonthCalendarView: View {
    @Binding var monthDate: Date
    let milestones: [Milestone]
    let onSelectDay: ([Milestone]) -> Void
    
    private let calendar = Calendar.current
    private let weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    var monthHeader: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: monthDate)
    }
    
    var totalEntriesInMonth: Int {
        let components = calendar.dateComponents([.year, .month], from: monthDate)
        return milestones.filter { milestone in
            guard let completedAt = milestone.completedAt else { return false }
            let entryComponents = calendar.dateComponents([.year, .month], from: completedAt)
            return entryComponents.year == components.year && entryComponents.month == components.month
        }.count
    }
    
    var daysInMonth: Int {
        let range = calendar.range(of: .day, in: .month, for: monthDate)!
        return range.count
    }
    
    var firstWeekdayOffset: Int {
        let components = calendar.dateComponents([.year, .month], from: monthDate)
        let firstDayOfMonth = calendar.date(from: components)!
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        return firstWeekday - 1
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Button(action: {
                    if let newDate = calendar.date(byAdding: .month, value: -1, to: monthDate) {
                        monthDate = newDate
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 36, height: 36)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text(monthHeader)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    if let newDate = calendar.date(byAdding: .month, value: 1, to: monthDate) {
                        monthDate = newDate
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.primary)
                        .frame(width: 36, height: 36)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
            }
            
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray.opacity(0.6))
                        .frame(maxWidth: .infinity)
                }
            }
            
            let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(0..<firstWeekdayOffset, id: \.self) { _ in
                    Spacer()
                        .frame(height: 44)
                }
                
                ForEach(1...daysInMonth, id: \.self) { day in
                    let date = dateForDay(day)
                    let dateMilestones = milestonesForDate(date)
                    
                    CalendarDayCell(day: day, isToday: calendar.isDateInToday(date), milestones: dateMilestones) {
                        onSelectDay(dateMilestones)
                    }
                }
            }
        }
    }
    
    private func dateForDay(_ day: Int) -> Date {
        var components = calendar.dateComponents([.year, .month], from: monthDate)
        components.day = day
        return calendar.date(from: components) ?? Date()
    }
    
    private func milestonesForDate(_ date: Date) -> [Milestone] {
        milestones.filter { milestone in
            guard let completedAt = milestone.completedAt else { return false }
            return calendar.isDate(completedAt, inSameDayAs: date)
        }
    }
}

struct CalendarDayCell: View {
    let day: Int
    let isToday: Bool
    let milestones: [Milestone]
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: {
            if !milestones.isEmpty {
                onSelect()
            }
        }) {
            ZStack {
                let count = milestones.count
                if count > 0 {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(red: 150/255, green: 180/255, blue: 80/255).opacity(min(1.0, 0.4 + Double(count) * 0.2)))
                        .aspectRatio(1, contentMode: .fit)
                    
                    Text("\(day)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                } else {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isToday ? Color(red: 150/255, green: 180/255, blue: 80/255).opacity(0.18) : Color(.systemGray6).opacity(0.5))
                        .aspectRatio(1, contentMode: .fit)
                    
                    Text("\(day)")
                        .font(.system(size: 16, weight: isToday ? .bold : .regular))
                        .foregroundColor(isToday ? Color(red: 140/255, green: 200/255, blue: 70/255) : .primary.opacity(0.5))
                }
            }
        }
        .buttonStyle(EmptyTabButtonStyle())
    }
}


// MARK: - Detail Sheet View
struct RecollectDetailSheet: View {
    let allMilestones: [Milestone]
    @State private var currentDate: Date
    @State private var selectedIndex = 0
    private let calendar = Calendar.current

    init(date: Date, allMilestones: [Milestone]) {
        self.allMilestones = allMilestones
        self._currentDate = State(initialValue: date)
    }

    // All unique days that have milestones, sorted oldest → newest
    private var datesWithMilestones: [Date] {
        let uniqueDays = Set(
            allMilestones.compactMap { $0.completedAt }
                .map { calendar.startOfDay(for: $0) }
        )
        return uniqueDays.sorted()
    }

    private var currentDateIndex: Int? {
        datesWithMilestones.firstIndex { calendar.isDate($0, inSameDayAs: currentDate) }
    }

    // Milestones that belong to the currently shown date
    private var currentDayMilestones: [Milestone] {
        allMilestones.filter {
            guard let completedAt = $0.completedAt else { return false }
            return calendar.isDate(completedAt, inSameDayAs: currentDate)
        }
    }

    private var activeMilestone: Milestone? {
        guard !currentDayMilestones.isEmpty else { return nil }
        let safeIndex = min(max(selectedIndex, 0), currentDayMilestones.count - 1)
        return currentDayMilestones[safeIndex]
    }

    private var formattedDate: String {
        PresentationHelpers.formattedDateOrdinal(currentDate)
    }

    private var emotionEmoji: String {
        guard let level = activeMilestone?.emotionLevel, level > 0 else { return "" }
        return ["😢", "😕", "😐", "🙂", "😄"][level - 1]
    }

    private func thumbnailSize(for count: Int) -> CGFloat {
        switch count {
        case 1: return 72
        case 2: return 68
        case 3: return 60
        case 4: return 52
        default: return 44
        }
    }

    private var hasPreviousDate: Bool {
        guard let idx = currentDateIndex else { return false }
        return idx > 0
    }

    private var hasNextDate: Bool {
        guard let idx = currentDateIndex else { return false }
        return idx < datesWithMilestones.count - 1
    }

    private func moveToPreviousDate() {
        guard let idx = currentDateIndex, idx > 0 else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            currentDate = datesWithMilestones[idx - 1]
            selectedIndex = 0
        }
    }

    private func moveToNextDate() {
        guard let idx = currentDateIndex, idx < datesWithMilestones.count - 1 else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            currentDate = datesWithMilestones[idx + 1]
            selectedIndex = 0
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer().frame(height: 12)

            // Date navigation header
            HStack {
                Button(action: moveToPreviousDate) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.gray.opacity(0.12)))
                }
                .disabled(!hasPreviousDate)
                .opacity(hasPreviousDate ? 1 : 0.3)

                Spacer()

                VStack(spacing: 2) {
                    Text(formattedDate)
                        .font(.headline).fontWeight(.bold)
                        .foregroundColor(.black)
                    Text("\(currentDayMilestones.count) finished lesson\(currentDayMilestones.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                Button(action: moveToNextDate) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.gray.opacity(0.12)))
                }
                .disabled(!hasNextDate)
                .opacity(hasNextDate ? 1 : 0.3)
            }
            .padding(.horizontal, 24)

            // Main photo card
            ZStack(alignment: .topLeading) {
                if let data = activeMilestone?.imageData,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(4/3, contentMode: .fill)
                        .frame(maxWidth: .infinity)
                        .clipped()
                } else {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.gray.opacity(0.15))
                        .frame(maxWidth: .infinity)
                        .aspectRatio(4/3, contentMode: .fill)
                }

                LinearGradient(
                    colors: [Color.black.opacity(0.65), Color.black.opacity(0.2), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(maxWidth: .infinity)
                .frame(height: 220)

                VStack(alignment: .leading, spacing: 6) {
                    Text(activeMilestone?.title ?? "Untitled")
                        .font(.title3).fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(activeMilestone?.content ?? "No details available.")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)
                }
                .padding(24)

                // Emoji from user's milestone emotion rating
                if !emotionEmoji.isEmpty {
                    VStack {
                        Spacer()
                        HStack {
                            Text(emotionEmoji)
                                .font(.system(size: 42))
                                .padding(.leading, 20)
                                .padding(.bottom, 16)
                            Spacer()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(4/3, contentMode: .fit)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color(.systemGray6))
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 24)

            // Thumbnail row — tap to switch milestone on the current day
            if currentDayMilestones.count > 1 {
                let tSize = thumbnailSize(for: currentDayMilestones.count)
                HStack(spacing: 12) {
                    ForEach(0..<currentDayMilestones.count, id: \.self) { index in
                        let milestone = currentDayMilestones[index]
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedIndex = index
                            }
                        }) {
                            if let data = milestone.imageData,
                               let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: tSize, height: tSize)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                                            .stroke(Color.appAccent, lineWidth: selectedIndex == index ? 3 : 0)
                                    )
                                    .shadow(color: Color.black.opacity(0.06), radius: 3)
                            } else {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(width: tSize, height: tSize)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(.gray)
                                    )
                            }
                        }
                        .buttonStyle(EmptyTabButtonStyle())
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .presentationDetents([.fraction(currentDayMilestones.count > 1 ? 0.81 : 0.70)])
        .presentationDragIndicator(.visible)
    }
}


#Preview {
    RecollectScreen()
        .modelContainer(for: [Item.self, Roadmap.self, Milestone.self], inMemory: true)
}
