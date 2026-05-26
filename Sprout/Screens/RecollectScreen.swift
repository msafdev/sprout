//
//  RecollectScreen.swift
//  Sprout
//
//  Created by Salman Alfarisi on 25/05/26.
//

import SwiftUI

struct RecollectScreen: View {
    @State private var entries: [RecollectEntry] = MockDataGenerator.getMockEntries()
    @State private var showingProfileSheet = false
    @State private var selectedEntry: RecollectEntry? = nil
    
    // Insights stats
    var weekCount: Int {
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return entries.filter { $0.date >= oneWeekAgo }.reduce(0) { $0 + $1.count }
    }
    
    var monthCount: Int {
        let calendar = Calendar.current
        let oneMonthAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        return entries.filter { $0.date >= oneMonthAgo }.reduce(0) { $0 + $1.count }
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
                        .fill(Color(red: 76/255, green: 175/255, blue: 80/255))
                )
                
                VStack(spacing: 32) {
                    ForEach(lastThreeMonths, id: \.self) { monthDate in
                        MonthCalendarView(monthDate: monthDate, entries: entries) { entry in
                            selectedEntry = entry
                        }
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
        }
        .background(Color.white)
        .sheet(isPresented: $showingProfileSheet) {
            ProfileSheetView()
        }
        .sheet(item: $selectedEntry) { entry in
            RecollectDetailSheet(entry: entry, allEntries: entries)
        }
    }
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
    let entries: [RecollectEntry]
    let onSelectEntry: (RecollectEntry) -> Void
    
    private let calendar = Calendar.current
    private let weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    
    var monthHeader: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: monthDate)
    }
    
    var totalEntriesInMonth: Int {
        let components = calendar.dateComponents([.year, .month], from: monthDate)
        return entries.filter { entry in
            let entryComponents = calendar.dateComponents([.year, .month], from: entry.date)
            return entryComponents.year == components.year && entryComponents.month == components.month
        }.reduce(0) { $0 + $1.count }
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
                    let entry = entryForDate(date)
                    
                    CalendarDayCell(day: day, isToday: calendar.isDateInToday(date), entry: entry) {
                        if let entry = entry {
                            onSelectEntry(entry)
                        }
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
    
    private func entryForDate(_ date: Date) -> RecollectEntry? {
        entries.first { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
    }
}

struct CalendarDayCell: View {
    let day: Int
    let isToday: Bool
    let entry: RecollectEntry?
    let onSelect: () -> Void
    
    var body: some View {
        ZStack {
            if let entry = entry {
                Button(action: onSelect) {
                    ZStack(alignment: .topTrailing) {
                        Image(entry.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                            .aspectRatio(1, contentMode: .fit)
                            .background(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(LinearGradient(
                                        colors: [entry.startColor, entry.endColor],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        
                        Text("\(day)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                        Text("\(entry.count)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .padding(4)
                            .background(
                                Circle()
                                    .fill(Color(red: 76/255, green: 175/255, blue: 80/255))
                            )
                            .offset(x: 5, y: -5)
                    }
                }
                .buttonStyle(EmptyTabButtonStyle())
            } else {
                ZStack {
                    if isToday {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(red: 76/255, green: 175/255, blue: 80/255).opacity(0.18))
                            .aspectRatio(1, contentMode: .fit)
                        
                        Text("\(day)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color(red: 76/255, green: 175/255, blue: 80/255))
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
    @State var entry: RecollectEntry
    let allEntries: [RecollectEntry]
    
    @State private var selectedItemIndex = 0
    @Environment(\.dismiss) private var dismiss
    
    private let calendar = Calendar.current
    
    var activeItem: EntryItem {
        if selectedItemIndex < entry.items.count {
            return entry.items[selectedItemIndex]
        }
        return entry.items.first ?? EntryItem(imageName: "placehold-1", title: "", description: "", bgGradientStart: "", bgGradientEnd: "")
    }
    
    // Returns thumbnail size based on entry count
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
                Button(action: moveToPreviousEntry) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.gray.opacity(0.12)))
                }
                .disabled(!hasPreviousEntry)
                .opacity(hasPreviousEntry ? 1 : 0.3)
                
                Spacer()
                
                VStack(spacing: 2) {
                    Text(formattedDateOrdinal(entry.date))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                    
                    Text("\(entry.items.count) items")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: moveToNextEntry) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 36, height: 36)
                        .background(Circle().fill(Color.gray.opacity(0.12)))
                }
                .disabled(!hasNextEntry)
                .opacity(hasNextEntry ? 1 : 0.3)
            }
            .padding(.horizontal, 24)
            
            // Image Card Container
            ZStack(alignment: .topLeading) {
                Image(activeItem.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: 380)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(LinearGradient(
                                colors: [Color.fromHex(activeItem.bgGradientStart), Color.fromHex(activeItem.bgGradientEnd)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    )
                
                LinearGradient(
                    colors: [Color.black.opacity(0.65), Color.black.opacity(0.2), Color.clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .frame(height: 220)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(activeItem.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(activeItem.description)
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)
                }
                .padding(24)
                
                VStack {
                    Spacer()
                    HStack {
                        // Drawing custom sprout/olive mascot
                        ZStack(alignment: .topTrailing) {
                            Ellipse()
                                .fill(Color(red: 139/255, green: 165/255, blue: 67/255))
                                .frame(width: 46, height: 50)
                                .overlay(
                                    VStack(spacing: 2) {
                                        HStack(spacing: 6) {
                                            Circle().fill(Color.black.opacity(0.8)).frame(width: 3, height: 3)
                                            Circle().fill(Color.black.opacity(0.8)).frame(width: 3, height: 3)
                                        }
                                        Capsule().stroke(Color.black.opacity(0.8), lineWidth: 1.5).frame(width: 6, height: 2)
                                    }
                                    .offset(y: 4)
                                )
                            
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(red: 139/255, green: 165/255, blue: 67/255))
                                .rotationEffect(.degrees(-35))
                                .offset(x: 2, y: -16)
                        }
                        .padding(.leading, 16)
                        .padding(.bottom, 48)
                        .shadow(color: Color.black.opacity(0.1), radius: 3)
                        
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 24)
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
            
            if entry.items.count > 1 {
                let tSize = thumbnailSize(for: entry.items.count)
                HStack(spacing: 12) {
                    ForEach(0..<entry.items.count, id: \.self) { index in
                        let item = entry.items[index]
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedItemIndex = index
                            }
                        }) {
                            Image(item.imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: tSize, height: tSize)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(Color(red: 76/255, green: 175/255, blue: 80/255), lineWidth: selectedItemIndex == index ? 3 : 0)
                                )
                                .shadow(color: Color.black.opacity(0.06), radius: 3)
                        }
                        .buttonStyle(EmptyTabButtonStyle())
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
            }
        }
        .background(Color(.systemBackground))
        .presentationDetents([.fraction(entry.items.count > 1 ? 0.81 : 0.70)])
        .presentationDragIndicator(.visible)
    }
    
    private var hasPreviousEntry: Bool {
        let sorted = allEntries.sorted(by: { $0.date < $1.date })
        if let idx = sorted.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: entry.date) }) {
            return idx > 0
        }
        return false
    }
    
    private var hasNextEntry: Bool {
        let sorted = allEntries.sorted(by: { $0.date < $1.date })
        if let idx = sorted.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: entry.date) }) {
            return idx < sorted.count - 1
        }
        return false
    }
    
    private func moveToPreviousEntry() {
        let sorted = allEntries.sorted(by: { $0.date < $1.date })
        if let idx = sorted.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: entry.date) }), idx > 0 {
            withAnimation {
                entry = sorted[idx - 1]
                selectedItemIndex = 0
            }
        }
    }
    
    private func moveToNextEntry() {
        let sorted = allEntries.sorted(by: { $0.date < $1.date })
        if let idx = sorted.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: entry.date) }), idx < sorted.count - 1 {
            withAnimation {
                entry = sorted[idx + 1]
                selectedItemIndex = 0
            }
        }
    }
    
    private func formattedDateOrdinal(_ date: Date) -> String {
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

#Preview {
    RecollectScreen()
}
