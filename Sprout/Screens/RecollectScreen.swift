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
    
    var lastThreeMonths: [Date] {
        let calendar = Calendar.current
        let today = Date()
        return (0..<3).compactMap { offset in
            calendar.date(byAdding: .month, value: -offset, to: today)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("Collection")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(.black)
                    
                    Spacer()
                    
                    Button(action: { showingProfileSheet = true }) {
                        Image(systemName: "person.crop.circle")
                            .font(.system(size: 28))
                            .foregroundColor(.black.opacity(0.8))
                    }
                }
                .padding(.top, 20)
                
                HStack(spacing: 40) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(weekCount)")
                            .font(.system(size: 46, weight: .semibold))
                            .foregroundColor(.white)
                        Text("This week")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(monthCount)")
                            .font(.system(size: 46, weight: .semibold))
                            .foregroundColor(.white)
                        Text("This month")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 22)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(red: 150/255, green: 180/255, blue: 80/255))
                )
                
                VStack(spacing: 32) {
                    ForEach(lastThreeMonths, id: \.self) { monthDate in
                        MonthCalendarView(monthDate: monthDate, milestones: completedMilestones) { dayMilestones in
                            if !dayMilestones.isEmpty {
                                selectedDaySelection = DaySelection(date: dayMilestones.first?.completedAt ?? Date(), milestones: dayMilestones)
                            }
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showingProfileSheet) {
            ProfileSheetView()
        }
        .sheet(item: $selectedDaySelection) { selection in
            RecollectDetailSheet(date: selection.date, milestones: selection.milestones)
        }
    }
}

struct DaySelection: Identifiable {
    let id = UUID()
    let date: Date
    let milestones: [Milestone]
}

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

struct MonthCalendarView: View {
    let monthDate: Date
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
                Text(monthHeader)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(totalEntriesInMonth) entries")
                    .font(.system(size: 15))
                    .foregroundColor(.gray.opacity(0.8))
            }
            
            HStack(spacing: 0) {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.gray.opacity(0.6))
                        .frame(maxWidth: .infinity)
                }
            }
            
            let columns = Array(repeating: GridItem(.flexible(), spacing: 6), count: 7)
            LazyVGrid(columns: columns, spacing: 10) {
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
    
    private var image: Image? {
        guard let data = milestones.first?.imageData,
              let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
    }
    
    var body: some View {
        ZStack {
            if !milestones.isEmpty {
                Button(action: onSelect) {
                    ZStack(alignment: .topTrailing) {
                        if let image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                .aspectRatio(1, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        } else {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.gray.opacity(0.15))
                                .aspectRatio(1, contentMode: .fit)
                        }
                        
                        Text("\(day)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        Text("\(milestones.count)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(4)
                            .background(
                                Circle()
                                    .fill(Color(red: 150/255, green: 180/255, blue: 80/255))
                            )
                            .offset(x: 5, y: -5)
                    }
                }
                .buttonStyle(EmptyTabButtonStyle())
            } else {
                ZStack {
                    if isToday {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(red: 150/255, green: 180/255, blue: 80/255).opacity(0.18))
                            .aspectRatio(1, contentMode: .fit)
                        
                        Text("\(day)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(red: 140/255, green: 200/255, blue: 70/255))
                    } else {
                        Text("\(day)")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.primary)
                    }
                }
                .frame(height: 40)
            }
        }
    }
}


// MARK: - Detail Sheet View
struct RecollectDetailSheet: View {
    let date: Date
    let milestones: [Milestone]
    @State private var selectedIndex = 0
    @Environment(\.dismiss) private var dismiss
    private let calendar = Calendar.current
    
    private var activeMilestone: Milestone? {
        guard !milestones.isEmpty else { return nil }
        let safeIndex = min(max(selectedIndex, 0), milestones.count - 1)
        return milestones[safeIndex]
    }
    
    private var formattedDate: String {
        PresentationHelpers.formattedDateOrdinal(date)
    }
    
    private var emotionText: String {
        guard let sentiment = activeMilestone?.emotionLevel else { return "" }
        switch sentiment {
        case 1: return "😢"
        case 2: return "😕"
        case 3: return "😐"
        case 4: return "🙂"
        case 5: return "😄"
        default: return ""
        }
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
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 12)
            
            HStack {
                Button(action: moveToPreviousMilestone) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.gray.opacity(0.12)))
                }
                .disabled(!hasPreviousMilestone)
                .opacity(hasPreviousMilestone ? 1 : 0.3)
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text(formattedDate)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text("\(milestones.count) finished lesson\(milestones.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: moveToNextMilestone) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.gray.opacity(0.12)))
                }
                .disabled(!hasNextMilestone)
                .opacity(hasNextMilestone ? 1 : 0.3)
            }
            .padding(.horizontal, 24)
            
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
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(activeMilestone?.content ?? "No details available.")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)
                }
                .padding(24)
                
                VStack {
                    Spacer()
                    HStack {
                        MascotSymbol()
                            .padding(.leading, 16)
                            .padding(.bottom, 48)
                        
                        Spacer()
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
            
            if milestones.count > 1 {
                let tSize = thumbnailSize(for: milestones.count)
                HStack(spacing: 12) {
                    ForEach(0..<milestones.count, id: \.self) { index in
                        let milestone = milestones[index]
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
                                            .stroke(Color(red: 76/255, green: 175/255, blue: 80/255), lineWidth: selectedIndex == index ? 3 : 0)
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
        .background(Color(.systemBackground))
        .presentationDetents([.fraction(milestones.count > 1 ? 0.81 : 0.70)])
        .presentationDragIndicator(.visible)
    }
    
    private var hasPreviousMilestone: Bool {
        selectedIndex > 0
    }
    
    private var hasNextMilestone: Bool {
        selectedIndex < milestones.count - 1
    }
    
    private func moveToPreviousMilestone() {
        if selectedIndex > 0 {
            withAnimation {
                selectedIndex -= 1
            }
        }
    }
    
    private func moveToNextMilestone() {
        if selectedIndex < milestones.count - 1 {
            withAnimation {
                selectedIndex += 1
            }
        }
    }
}


#Preview {
    RecollectScreen()
        .modelContainer(for: [Item.self, Roadmap.self, Milestone.self], inMemory: true)
}
