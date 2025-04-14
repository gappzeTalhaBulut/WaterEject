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
    private let appStorage: AppStorageManager
    @State private var days: [DayIndicator] = []
    
    init(appStorage: AppStorageManager = AppStorageManager()) {
        self.appStorage = appStorage
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                // İleride detay sayfasına yönlendirme yapılabilir
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("7-day cleaning Plan:")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Perform a complete cleaning by daily cleaning")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                }
                .padding(.horizontal)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(days) { day in
                        DayCircleView(day: day.day, isCompleted: day.isCompleted)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(uiColor: .systemBlue).opacity(0.2))
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
    
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(isCompleted ? Color.white : Color.gray.opacity(0.3), lineWidth: isCompleted ? 3 : 1)
                .background(Circle().fill(isCompleted ? Color.blue : Color.clear))
                .frame(width: 40, height: 40)
            
            VStack(spacing: 2) {
                Text("\(day)")
                    .foregroundColor(isCompleted ? .white : .gray)
                    .font(.system(size: 16, weight: .bold))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isCompleted)
    }
}

#Preview {
    VStack {
        SevenDayCleaningView()
            .padding()
        
        // Preview için farklı durumları göster
        HStack(spacing: 12) {
            DayCircleView(day: 1, isCompleted: false)
            DayCircleView(day: 2, isCompleted: true)
        }
        .padding()
    }
    .frame(maxWidth: .infinity)
    .background(Color.black)
}
