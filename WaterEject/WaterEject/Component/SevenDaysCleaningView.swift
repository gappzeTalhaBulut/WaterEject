//
//  SevenDaysCleaningView.swift
//  WaterEject
//
//  Created by Talha on 14.04.2025.
//

import SwiftUI
import UserNotifications

struct DayIndicator: Identifiable, Codable {
    let id: UUID
    let day: Int  // 1-7 arası gün numarası
    var isCompleted: Bool
    var date: Date
}

class CleaningProgress: ObservableObject {
    static let shared = CleaningProgress()
    @Published var lastCleaningDate: Date?
    @Published var shouldRefreshDays: Bool = false
    
    func markDayAsCompleted() {
        lastCleaningDate = Date()
        shouldRefreshDays = true
    }
}

struct SevenDayCleaningView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var cleaningProgress: CleaningProgress
    private let appStorage: AppStorageManager
    @State private var days: [DayIndicator] = []
    @State private var showFeedback: Bool = false
    
    init(appStorage: AppStorageManager = AppStorageManager()) {
        self.appStorage = appStorage
    }
    
    private var backgroundGradient: LinearGradient {
        let darkBlue = Color.blue.opacity(colorScheme == .dark ? 0.2 : 0.1)
        let lightBlue = Color.blue.opacity(colorScheme == .dark ? 0.1 : 0.05)
        return LinearGradient(
            colors: [darkBlue, lightBlue],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var textColor: Color {
        colorScheme == .dark ? .white : .primary
    }
    
    private var subtitleColor: Color {
        colorScheme == .dark ? .gray : .secondary
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                // İleride detay sayfasına yönlendirme yapılabilir
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("7-day cleaning Plan:")
                            .font(.headline)
                            .foregroundColor(textColor)
                        
                        Text("Perform a complete cleaning by daily cleaning")
                            .font(.subheadline)
                            .foregroundColor(subtitleColor)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(days) { day in
                        DayCircleView(
                            day: day.day,
                            isCompleted: day.isCompleted,
                            colorScheme: colorScheme
                        )
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(backgroundGradient)
        .cornerRadius(12)
        .onAppear {
            loadDays()
            requestNotificationPermission()
        }
        .onChange(of: cleaningProgress.lastCleaningDate) { _ in
            markDayAsCompletedAfterCleaning()
        }
        .alert("Day Completed!", isPresented: $showFeedback) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Great! You've completed today's cleaning task.")
        }
    }
    
    private func loadDays() {
        if let savedDays = try? JSONDecoder().decode([DayIndicator].self, from: appStorage.cleaningDaysData) {
            days = savedDays
        } else {
            // İlk kez oluşturuluyorsa, 7 günlük plan oluştur
            days = (1...7).map { day in
                DayIndicator(
                    id: UUID(),
                    day: day,
                    isCompleted: false,
                    date: Date()
                )
            }
            saveDays()
        }
    }
    
    private func saveDays() {
        if let encoded = try? JSONEncoder().encode(days) {
            appStorage.cleaningDaysData = encoded
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notification permission granted")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    private func markDayAsCompletedAfterCleaning() {
        // Find the current active day
        let currentDay = getCurrentActiveDay()
        if let index = days.firstIndex(where: { $0.day == currentDay }) {
            if !days[index].isCompleted {
                days[index].isCompleted = true
                days[index].date = Date() // Save completion date
                saveDays()
                showFeedback = true
                
                // Only schedule next notification if we haven't completed all 7 days
                if !days.allSatisfy({ $0.isCompleted }) {
                    schedulePushNotification(forDay: days[index].date)
                }
            }
        }
    }
    
    private func getCurrentActiveDay() -> Int {
        // If no days are completed, return day 1
        if !days.contains(where: { $0.isCompleted }) {
            return 1
        }
        
        // Find the last completed day
        if let lastCompletedDay = days.filter({ $0.isCompleted })
            .sorted(by: { $0.date > $1.date })
            .first {
            
            // Check if 24 hours have passed since the last completion
            if let daysPassed = Calendar.current.dateComponents([.hour],
                from: lastCompletedDay.date,
                to: Date()).hour,
               daysPassed >= 24 {
                
                // Find the next uncompleted day
                if let nextDay = days.first(where: { !$0.isCompleted })?.day {
                    return nextDay
                }
            }
            
            // If 24 hours haven't passed, return the current day
            return lastCompletedDay.day
        }
        
        return 1 // Default to day 1 if something goes wrong
    }
    
    private func schedulePushNotification(forDay date: Date) {
        // Don't schedule if all days are completed
        if days.allSatisfy({ $0.isCompleted }) {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Water Eject Cleaning"
        content.body = "Time to clean your device's speaker! Complete today's cleaning task."
        content.sound = .default
        
        // Schedule for 24 hours from now
        let nextDate = Calendar.current.date(byAdding: .hour, value: 24, to: date) ?? date
        let components = Calendar.current.dateComponents([.hour, .minute], from: nextDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "cleaning-reminder-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling next day notification: \(error)")
            } else {
                print("Next day notification scheduled successfully")
            }
        }
    }
}

struct DayCircleView: View {
    let day: Int
    let isCompleted: Bool
    let colorScheme: ColorScheme
    
    private var circleColor: Color {
        if isCompleted {
            return colorScheme == .dark ? .blue : .blue.opacity(0.9)
        } else {
            return .clear
        }
    }
    
    private var borderColor: Color {
        if isCompleted {
            return colorScheme == .dark ? .white : .white
        } else {
            return colorScheme == .dark ? .gray.opacity(0.3) : .gray.opacity(0.4)
        }
    }
    
    private var textColor: Color {
        if isCompleted {
            return .white
        } else {
            return colorScheme == .dark ? .gray : .gray.opacity(0.8)
        }
    }
    
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(borderColor, lineWidth: isCompleted ? 3 : 1)
                .background(Circle().fill(circleColor))
                .frame(width: 40, height: 40)
                //.shadow(color: isCompleted ? .blue.opacity(0.3) : .clear, radius: 4)
            
            VStack(spacing: 2) {
                Text("\(day)")
                    .foregroundColor(textColor)
                    .font(.system(size: 16, weight: .bold))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isCompleted)
    }
}

#Preview {
    Group {
        // Dark mode preview with sample data
        VStack(spacing: 20) {
            // Test Case 1: İlk 3 gün tamamlanmış
            SevenDayCleaningView(appStorage: PreviewAppStorage(days: [
                DayIndicator(id: UUID(), day: 1, isCompleted: true, date: Date()),
                DayIndicator(id: UUID(), day: 2, isCompleted: true, date: Date()),
                DayIndicator(id: UUID(), day: 3, isCompleted: true, date: Date()),
                DayIndicator(id: UUID(), day: 4, isCompleted: false, date: Date()),
                DayIndicator(id: UUID(), day: 5, isCompleted: false, date: Date()),
                DayIndicator(id: UUID(), day: 6, isCompleted: false, date: Date()),
                DayIndicator(id: UUID(), day: 7, isCompleted: false, date: Date())
            ]))
            .padding()
            
            // Test Case 2: Rastgele günler tamamlanmış
            SevenDayCleaningView(appStorage: PreviewAppStorage(days: [
                DayIndicator(id: UUID(), day: 1, isCompleted: true, date: Date()),
                DayIndicator(id: UUID(), day: 2, isCompleted: false, date: Date()),
                DayIndicator(id: UUID(), day: 3, isCompleted: true, date: Date()),
                DayIndicator(id: UUID(), day: 4, isCompleted: false, date: Date()),
                DayIndicator(id: UUID(), day: 5, isCompleted: true, date: Date()),
                DayIndicator(id: UUID(), day: 6, isCompleted: false, date: Date()),
                DayIndicator(id: UUID(), day: 7, isCompleted: false, date: Date())
            ]))
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemBackground))
    }
}

class PreviewAppStorage: AppStorageManager {
    init(days: [DayIndicator]) {
        super.init()
        if let encoded = try? JSONEncoder().encode(days) {
            self.cleaningDaysData = encoded
        }
    }
}
