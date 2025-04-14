//
//  WaterEjectViewModel.swift
//  WaterEject
//
//  Created by Talha on 13.03.2025.
//

import Foundation
import UIKit

class WaterEjectViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var progress: Double = 0.0
    @Published var currentPhase = ""
    
    private let audioEngine = AudioEngine()
    private var progressTimer: Timer?
    private let appStorage: AppStorageManager
    
    init(appStorage: AppStorageManager = AppStorageManager()) {
        self.appStorage = appStorage
        
        audioEngine.onPlaybackComplete = { [weak self] in
            DispatchQueue.main.async {
                self?.isPlaying = false
                self?.progress = 0.0
                self?.currentPhase = ""
            }
        }
    }
    
    func startWaterEject() {
        guard !isPlaying else { return }
        
        isPlaying = true
        progress = 0.0
        currentPhase = "Starting cleaning..."
        
        // More gradual frequency changes with overlap
        let frequencies: [(Float, TimeInterval)] = [
            (165, 8.0),  // Low frequency start
            (200, 8.0),  // Gradual increase
            (235, 8.0),  // Mid-low frequency
            (280, 8.0),  // Mid frequency
            (320, 8.0),  // Mid-high frequency
            (380, 8.0),  // Higher
            (440, 8.0),  // Peak frequency
            (380, 8.0),  // Gradual decrease
            (320, 8.0),  // Back down
            (280, 8.0),  // Continue down
            (235, 8.0),  // Almost done
            (165, 8.0)   // Final sweep
        ]
        
        // Total duration is now 96 seconds
        startProgressTimer(totalDuration: 96.0)
        audioEngine.playFrequenciesSequence(frequencies: frequencies)
    }
    
    private func startProgressTimer(totalDuration: TimeInterval) {
        progressTimer?.invalidate()
        let interval = 0.1
        
        progressTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            self.progress += interval / totalDuration
            
            // Update phase description
            if self.progress < 0.25 {
                self.currentPhase = "Low frequency cleaning..."
            } else if self.progress < 0.5 {
                self.currentPhase = "Mid frequency cleaning..."
            } else if self.progress < 0.75 {
                self.currentPhase = "High frequency cleaning..."
            } else {
                self.currentPhase = "Final phase..."
            }
            
            if self.progress >= 1.0 {
                self.stopSession()
                // Cleaning completed, mark the day
                self.cleaningCompleted()
            }
        }
    }
    
    private func cleaningCompleted() {
        markCurrentDayAsCompleted()
        schedulePushNotificationForNextDay()
        incrementCurrentDay()
    }
    
    private func markCurrentDayAsCompleted() {
        if var savedDays = try? JSONDecoder().decode([DayIndicator].self, from: appStorage.cleaningDaysData) {
            if let index = savedDays.firstIndex(where: { $0.day == getCurrentDay() }) {
                savedDays[index].isCompleted = true
                if let encoded = try? JSONEncoder().encode(savedDays) {
                    appStorage.cleaningDaysData = encoded
                }
            }
        }
    }
    
    private func getCurrentDay() -> Int {
        let defaults = UserDefaults.standard
        let currentDay = defaults.integer(forKey: "currentCleaningDay")
        if currentDay == 0 || currentDay > 7 {
            defaults.set(1, forKey: "currentCleaningDay")
            return 1
        }
        return currentDay
    }
    
    private func incrementCurrentDay() {
        let defaults = UserDefaults.standard
        var currentDay = defaults.integer(forKey: "currentCleaningDay")
        currentDay += 1
        if currentDay > 7 {
            currentDay = 1 // Reset to day 1 after completing 7 days
        }
        defaults.set(currentDay, forKey: "currentCleaningDay")
    }
    
    private func schedulePushNotificationForNextDay() {
        let content = UNMutableNotificationContent()
        content.title = "Water Eject Cleaning"
        content.body = "Time to clean your device's speaker! Complete today's cleaning task."
        content.sound = .default
        
        // Schedule for tomorrow at the same time
        var components = Calendar.current.dateComponents([.hour, .minute], from: Date())
        components.day = Calendar.current.component(.day, from: Date()) + 1
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: "cleaning-reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func stopSession() {
        progressTimer?.invalidate()
        progressTimer = nil
        isPlaying = false
        progress = 0.0
        currentPhase = ""
        audioEngine.stopPlayback()
    }
    
    deinit {
        progressTimer?.invalidate()
    }
}
