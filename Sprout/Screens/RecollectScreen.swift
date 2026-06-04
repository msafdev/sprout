//
//  RecollectScreen.swift
//  Sprout
//
//  Created by Salman Alfarisi on 25/05/26.
//

import SwiftUI
import SwiftData
import UserNotifications

struct RecollectScreen: View {
    @Query(sort: \Milestone.createdAt, order: .reverse) private var milestones: [Milestone]
    
    @State private var showingProfileSheet = false
    // Use NavigationPath for drill-down navigation
    @State private var navigationPath = NavigationPath()
    @State private var currentCalendarMonthDate = Date()
    
    private var completedMilestones: [Milestone] {
        milestones
            .filter { $0.isCompleted && $0.completedAt != nil }
            .sorted { ($0.completedAt ?? .distantPast) > ($1.completedAt ?? .distantPast) }
    }
    
    var weekCount: Int {
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return completedMilestones.filter { ($0.completedAt ?? .distantPast) >= oneWeekAgo }.count
    }
    
    var monthCount: Int {
        let calendar = Calendar.current
        let oneMonthAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return completedMilestones.filter { ($0.completedAt ?? .distantPast) >= oneMonthAgo }.count
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                AppGradientBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        // Weekly / Monthly Stats
                        HStack(spacing: 12) {
                            StatsCard(title: "This week", count: weekCount, icon: "drop.fill", colors: ["#5F6F52", "#A9B388"])
                            StatsCard(title: "This month", count: monthCount, icon: "leaf.fill", colors: ["#8F8E2C", "#C7C670"])
                        }
                        
                        // Calendar
                        MonthCalendarView(monthDate: $currentCalendarMonthDate, milestones: completedMilestones) { dayMilestones in
                            if let date = dayMilestones.first?.completedAt {
                                // Navigate by appending to the path
                                navigationPath.append(DaySelection(date: date, milestones: dayMilestones))
                            }
                        }
                        .padding(20)
                        .background(Color.appCard)
                        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 4)
                        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.black.opacity(0.04), lineWidth: 1))
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Collection")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { showingProfileSheet = true }) {
                        Image(systemName: "person.crop.circle").font(.system(size: 24))
                    }
                }
            }
            // Define the navigation target
            .navigationDestination(for: DaySelection.self) { selection in
                RecollectDetailView(date: selection.date, allMilestones: completedMilestones)
            }
            .sheet(isPresented: $showingProfileSheet) {
                ProfileSheetView()
            }
        }
    }
}

// MARK: - Helper View for Stats
struct StatsCard: View {
    let title: String
    let count: Int
    let icon: String
    let colors: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 36) {
            HStack(alignment: .top) {
                Image(systemName: icon).font(.system(size: 28)).foregroundColor(.white)
                Spacer()
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 18, weight: .bold, design: .rounded)).foregroundColor(.white)
                Text("\(count) done").font(.system(size: 15, weight: .medium, design: .rounded)).foregroundColor(.white.opacity(0.85))
            }
        }
        .padding(20).frame(maxWidth: .infinity)
        .background(LinearGradient(colors: colors.map { Color.fromHex($0) }, startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(Color.white.opacity(0.25), lineWidth: 1.5))
    }
}

struct DaySelection: Hashable {
    let date: Date
    let milestones: [Milestone]
}

// MARK: - Fixed Month Calendar View
struct MonthCalendarView: View {
    @Binding var monthDate: Date
    let milestones: [Milestone]
    let onSelectDay: ([Milestone]) -> Void
    
    private let calendar = Calendar.current
    private let weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    // 👇 States to manage the jump-to selector sheet
    @State private var showDatePickerSheet = false
    @State private var selectedMonth = 1
    @State private var selectedYear = 2026
    
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
        guard let range = calendar.range(of: .day, in: .month, for: monthDate) else { return 30 }
        return range.count
    }
    
    var firstWeekdayOffset: Int {
        let components = calendar.dateComponents([.year, .month], from: monthDate)
        guard let firstDayOfMonth = calendar.date(from: components) else { return 0 }
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        return firstWeekday - 1
    }
    
    // Add this computed property inside your MonthCalendarView to create a stable ID
    private var calendarMonthID: String {
        let components = calendar.dateComponents([.year, .month], from: monthDate)
        return "\(components.year ?? 2026)-\(components.month ?? 1)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Month Switcher Header
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
                
                // 👇 Turned the header text into a button to trigger the picker
                Button(action: {
                    let components = calendar.dateComponents([.year, .month], from: monthDate)
                    selectedMonth = components.month ?? 1
                    selectedYear = components.year ?? 2026
                    showDatePickerSheet = true
                }) {
                    VStack(spacing: 2) {
                        HStack(spacing: 4) {
                            Text(monthHeader)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.primary)
                            Image(systemName: "chevron.down")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.gray)
                        }
                        Text("\(totalEntriesInMonth) entries")
                            .font(.system(size: 12))
                            .foregroundColor(.gray.opacity(0.8))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
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
            
            // Weekday Row
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.primary.opacity(0.7))
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Grid
                    let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
                    
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(0..<firstWeekdayOffset, id: \.self) { _ in
                            // Fixed: Changed Spacer() to Color.clear for grid cell stability
                            Color.clear
                                .frame(height: 44)
                        }
                        
                        ForEach(1...daysInMonth, id: \.self) { day in
                            let date = dateForDay(day)
                            let dateMilestones = milestonesForDate(date)
                            
                            CalendarDayCell(
                                day: day,
                                isToday: calendar.isDateInToday(date),
                                milestones: dateMilestones
                            ) {
                                onSelectDay(dateMilestones)
                            }
                        }
                    }
                    // 👇 CRITICAL FIX: Forces SwiftUI to reset layout cache when the month changes
                    .id(calendarMonthID)
                }
                .onAppear {
                    print("Calendar appearing for: \(monthHeader)")
                }
        // 👇 Bottom sheet configuration for picking month & year explicitly
        .sheet(isPresented: $showDatePickerSheet) {
            VStack(spacing: 0) {
                HStack {
                    Text("Jump to Date")
                        .font(.headline)
                    Spacer()
                    Button("Done") {
                        var components = calendar.dateComponents([.hour, .minute, .second], from: monthDate)
                        components.year = selectedYear
                        components.month = selectedMonth
                        components.day = 1 // Normalize to first of the month
                        
                        if let targetDate = calendar.date(from: components) {
                            monthDate = targetDate
                        }
                        showDatePickerSheet = false
                    }
                    .font(.body)
                    .fontWeight(.semibold)
                }
                .padding()
                
                Divider()
                
                HStack(spacing: 0) {
                    // Month Picker Wheel
                    Picker("Month", selection: $selectedMonth) {
                        ForEach(1...12, id: \.self) { m in
                            Text(calendar.monthSymbols[m - 1]).tag(m)
                        }
                    }
                    .pickerStyle(.wheel)
                    
                    // Year Picker Wheel
                    Picker("Year", selection: $selectedYear) {
                        ForEach(2020...2035, id: \.self) { y in
                            Text(String(y)).tag(y)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                .padding(.horizontal)
            }
            .presentationDetents([.height(260)]) // Restricts container to just fit the wheels cleanly
        }
    }
    
    // Helper to keep structural compilation clean inside LazyVGrid
    @ViewBuilder
    private func ForGrid(_ range: ClosedRange<Int>) -> some View {
        ForEach(range, id: \.self) { day in
            let date = dateForDay(day)
            let dateMilestones = milestonesForDate(date)
            
            CalendarDayCell(
                day: day,
                isToday: calendar.isDateInToday(date),
                milestones: dateMilestones
            ) {
                onSelectDay(dateMilestones)
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
// MARK: - Gaby's Visual Calendar Cell Style
struct CalendarDayCell: View {
    let day: Int
    let isToday: Bool
    let milestones: [Milestone]
    let onSelect: () -> Void
    
    // 1. UPDATED: Find the first milestone that actually has image data
    private var cellImage: Image? {
        guard let milestoneWithImage = milestones.first(where: { $0.imageData != nil }),
              let data = milestoneWithImage.imageData,
              let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
    }
    
    var body: some View {
        Button(action: {
            if !milestones.isEmpty {
                onSelect()
            }
        }) {
            ZStack {
                let count = milestones.count
                
                if count > 0 {
                    // Photo-based cell when milestones exist
                    ZStack(alignment: .topTrailing) {
                        if let cellImage {
                            // User's uploaded photo
                            cellImage
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                .aspectRatio(1, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .clipped()
                        } else {
                            // 2. UPDATED: Fallback placeholder image when database returns nil
                            Image("sus") // <-- Put your asset name here
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                .aspectRatio(1, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .clipped()
                        }
                        
                        // Dark overlay for legibility
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.black.opacity(0.25))
                        
                        Text("\(day)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        // Numeric Milestone Badge Indicator
                        Text("\(count)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Circle().fill(Color.appAccent))
                            .offset(x: 4, y: -4)
                    }
                } else {
                    // Clean Empty Day Cell Structure
                    if isToday {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.appAccent, lineWidth: 2)
                            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(Color.appAccent.opacity(0.12)))
                            .aspectRatio(1, contentMode: .fit)
                        
                        Text("\(day)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.appAccent)
                    } else {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(.systemGray6).opacity(0.4))
                            .aspectRatio(1, contentMode: .fit)
                        
                        Text("\(day)")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.primary.opacity(0.75))
                    }
                }
            }
        }
        .buttonStyle(EmptyTabButtonStyle())
    }
}
// MARK: - Profile & Settings View
struct ProfileSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("reduceMotion") private var reduceMotion = false

    @State private var showNotificationDeniedAlert = false

    var body: some View {
        NavigationStack {
            List {
                // MARK: Preferences
                Section(header: Text("Preferences")) {
                    Toggle(isOn: $reduceMotion) {
                        Label("Reduce Motion", systemImage: "hand.raised.fill")
                    }

                    Toggle(isOn: $notificationsEnabled) {
                        Label("Daily Reminder", systemImage: "bell.fill")
                    }
                    .onChange(of: notificationsEnabled) { _, enabled in
                        if enabled {
                            requestAndScheduleNotification()
                        } else {
                            cancelDailyNotification()
                        }
                    }
                }

                // MARK: About
                Section(header: Text("About")) {
                    LabeledContent("App Version", value: "1.0.0")
                    LabeledContent("Developer", value: "Team 18")
                }
            }
            .navigationTitle("Profile & Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .alert("Notifications Disabled", isPresented: $showNotificationDeniedAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) {
                    notificationsEnabled = false
                }
            } message: {
                Text("Please enable notifications for Sprout in Settings to receive daily reminders.")
            }
        }
    }

    // MARK: - Notification Helpers

    private func requestAndScheduleNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    scheduleDailyNotification()
                } else {
                    notificationsEnabled = false
                    showNotificationDeniedAlert = true
                }
            }
        }
    }

    private func scheduleDailyNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Sprout 🌱"
        content.body = "Don't forget to water your plants!"
        content.sound = .default

        var components = DateComponents()
        components.hour = 8
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "sprout.daily.reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func cancelDailyNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["sprout.daily.reminder"])
    }

}

struct AccessibilityIdeaRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(title, systemImage: icon)
                .font(.subheadline).fontWeight(.semibold)
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    RecollectScreen()
        .modelContainer(for: [Milestone.self], inMemory: true)
}
