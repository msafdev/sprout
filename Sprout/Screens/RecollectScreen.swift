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
                        .background(Color.white)
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
                Image(systemName: "ellipsis").font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                    .frame(width: 28, height: 28).background(Color.black.opacity(0.12)).clipShape(Circle())
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
                
                VStack(spacing: 2) {
                    Text(monthHeader)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    Text("\(totalEntriesInMonth) entries")
                        .font(.system(size: 12))
                        .foregroundColor(.gray.opacity(0.8))
                }
                
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
                    Spacer()
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
        }
        // Add this to your MonthCalendarView inside the body
        .onAppear {
            print("Calendar appearing for: \(monthHeader)")
        }
    }
    
    
    // Fixed: Pulls structural components explicitly matching current calendar calculation contexts
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
    
    // Logic to extract image from milestones
    private var cellImage: Image? {
        guard let data = milestones.first?.imageData,
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
                            cellImage
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                .aspectRatio(1, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .clipped()
                        } else {
                            // Fallback if milestone exists but image data is missing
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.appAccent.opacity(min(1.0, 0.4 + Double(count) * 0.18)))
                                .aspectRatio(1, contentMode: .fit)
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
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Account")) {
                    HStack {
                        Image(systemName: "person.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color.blue))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Salman Alfarisi")
                                .font(.headline)
                            Text("salman@sprout.com")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("Preferences")) {
                    HStack {
                        Label("Notifications", systemImage: "bell.fill")
                        Spacer()
                        Toggle("", isOn: .constant(true)).labelsHidden()
                    }
                    
                    HStack {
                        Label("Dark Mode", systemImage: "moon.fill")
                        Spacer()
                        Toggle("", isOn: .constant(false)).labelsHidden()
                    }
                }
                
                Section(header: Text("About")) {
                    LabeledContent("App Version", value: "1.0.0")
                    LabeledContent("Developer", value: "Salman Alfarisi")
                }
            }
            .navigationTitle("Profile & Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    RecollectScreen()
        .modelContainer(for: [Milestone.self], inMemory: true)
}
