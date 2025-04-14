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
    let day: Int
    var isCompleted: Bool
    var date: Date
}

struct SevenDayCleaningView: View {
    @Environment(\.colorScheme) var colorScheme
    private let appStorage: AppStorageManager
    @State private var days: [DayIndicator] = []
    
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
        }
    }
    
    private func loadDays() {
        if let savedDays = try? JSONDecoder().decode([DayIndicator].self, from: appStorage.cleaningDaysData) {
            days = savedDays
        } else {
            // İlk kez oluşturuluyorsa
            days = (1...7).map { day in
                DayIndicator(
                    id: UUID(),
                    day: day,
                    isCompleted: false,
                    date: Calendar.current.date(byAdding: .day, value: day - 1, to: Date()) ?? Date()
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
    
    func markDayAsCompleted(day: Int) {
        if let index = days.firstIndex(where: { $0.day == day }) {
            days[index].isCompleted = true
            saveDays()
            
            // Push notification'ı planla
            schedulePushNotification(forDay: days[index].date)
        }
    }
    
    private func schedulePushNotification(forDay date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Water Eject Cleaning"
        content.body = "Time to clean your device's speaker! Complete today's cleaning task."
        content.sound = .default
        
        // Bir sonraki gün için bildirim
        let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
        let components = Calendar.current.dateComponents([.hour, .minute], from: nextDay)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "cleaning-reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
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
                .shadow(color: isCompleted ? .blue.opacity(0.3) : .clear, radius: 4)
            
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
        // Dark mode preview
        VStack {
            SevenDayCleaningView()
                .padding()
            
            HStack(spacing: 12) {
                DayCircleView(day: 1, isCompleted: false, colorScheme: .dark)
                DayCircleView(day: 2, isCompleted: true, colorScheme: .dark)
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Color.black)
        .environment(\.colorScheme, .dark)
        
        // Light mode preview
        VStack {
            SevenDayCleaningView()
                .padding()
            
            HStack(spacing: 12) {
                DayCircleView(day: 1, isCompleted: false, colorScheme: .light)
                DayCircleView(day: 2, isCompleted: true, colorScheme: .light)
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .environment(\.colorScheme, .light)
    }
}
