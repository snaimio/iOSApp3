//
//  HydrationManager.swift
//  Hydration Watch App
//
//  Created by Sheikh Naim on 2026-06-18.
//

import Foundation
import WatchKit
import UserNotifications
import Combine
import SwiftUI

@MainActor
final class HydrationManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var todayIntake = 0
    @Published var goal = 3000
    @Published var streak = 0
    @Published var history: [DailyRecord] = []
    @Published var todayEntries: [DrinkEntry] = []
    @Published var reminderSettings = ReminderSettings()
    @Published var reminderInterval: String = "1 hour"
    @Published var showOverhydrationAlert = false
    @Published var weight: Int = 70
    
    // MARK: - Storage Keys
    private let intakeKey = "todayIntake"
    private let goalKey = "goal"
    private let historyKey = "history"
    private let streakKey = "streak"
    private let entriesKey = "todayEntries"
    private let lastDateKey = "lastDate"
    private let reminderIntervalKey = "reminderInterval"
    private let weightKey = "userWeight"
    
    // MARK: - Computed Properties
    var progress: Double {
        guard goal > 0 else { return 0 }
        return min(1.0, Double(todayIntake) / Double(goal))
    }
    
    var remaining: Int {
        max(0, goal - todayIntake)
    }
    
    // MARK: - Overhydration Limits
    var maxSafeWaterPerDay: Int {
        return min(weight * 100, 12000)
    }
    
    var isOverHydrated: Bool {
        return todayIntake > maxSafeWaterPerDay
    }
    
    var overHydrationLevel: OverHydrationLevel {
        let ratio = Double(todayIntake) / Double(maxSafeWaterPerDay)
        if ratio < 1.0 { return .normal }
        if ratio < 1.2 { return .slightlyOver }
        if ratio < 1.5 { return .moderatelyOver }
        return .severelyOver
    }
    
    enum OverHydrationLevel {
        case normal
        case slightlyOver
        case moderatelyOver
        case severelyOver
        
        var message: String {
            switch self {
            case .normal:
                return "Stay hydrated! 💪"
            case .slightlyOver:
                return "You're above the safe daily limit. Consider slowing down! ⚠️"
            case .moderatelyOver:
                return "You're well above the safe limit. Please be careful! ⚠️"
            case .severelyOver:
                return "🚨 DANGER: You've consumed too much water! Please stop and seek medical attention if you feel unwell."
            }
        }
        
        var color: Color {
            switch self {
            case .normal:
                return .blue
            case .slightlyOver:
                return .orange
            case .moderatelyOver:
                return .red
            case .severelyOver:
                return .red
            }
        }
        
        var emoji: String {
            switch self {
            case .normal:
                return "💪"
            case .slightlyOver:
                return "⚠️"
            case .moderatelyOver:
                return "⚡"
            case .severelyOver:
                return "🚨"
            }
        }
    }
    
    // MARK: - Statistics
    var totalDays: Int {
        return history.count
    }
    
    var averageIntake: Int {
        guard !history.isEmpty else { return 0 }
        let total = history.reduce(0) { $0 + $1.intake }
        return total / history.count
    }
    
    var bestDay: DailyRecord? {
        return history.max(by: { $0.intake < $1.intake })
    }
    
    var totalIntakeAllTime: Int {
        return history.reduce(0) { $0 + $1.intake }
    }
    
    var daysMetGoal: Int {
        return history.filter { $0.progress >= 1.0 }.count
    }
    
    var completionRate: Double {
        guard !history.isEmpty else { return 0 }
        return Double(daysMetGoal) / Double(history.count)
    }
    
    // MARK: - Weekly Data for Chart
    var weeklyData: [(String, Double)] {
        let calendar = Calendar.current
        let weekdays = ["M", "T", "W", "T", "F", "S", "S"]
        let today = Date()
        
        return weekdays.enumerated().map { index, day in
            let date = calendar.date(byAdding: .day, value: -(6 - index), to: today) ?? today
            let startOfDay = calendar.startOfDay(for: date)
            let record = history.first { calendar.isDate($0.date, inSameDayAs: startOfDay) }
            let progress = record?.progress ?? 0
            return (day, progress)
        }
    }
    
    // MARK: - Init
    init() {
        load()
        checkNewDay()
        loadReminderInterval()
        loadWeight()
    }
    
    // MARK: - Core Functions
    func addWater(_ amount: Int) {
        todayIntake += amount
        todayEntries.append(DrinkEntry(amount: amount, time: Date()))
        
        WKInterfaceDevice.current().play(.click)
        
        if todayIntake >= goal && !isOverHydrated {
            WKInterfaceDevice.current().play(.success)
            sendGoalNotification()
        }
        
        if isOverHydrated {
            WKInterfaceDevice.current().play(.failure)
            sendOverhydrationWarning()
            showOverhydrationAlert = true
        }
        
        save()
    }
    
    func undoLastEntry() {
        guard let last = todayEntries.last else { return }
        
        todayEntries.removeLast()
        todayIntake -= last.amount
        
        if showOverhydrationAlert {
            showOverhydrationAlert = false
        }
        
        save()
        WKInterfaceDevice.current().play(.click)
    }
    
    func resetDay() {
        let record = DailyRecord(date: Date(), intake: todayIntake, goal: goal)
        history.insert(record, at: 0)
        
        if history.count > 30 {
            history = Array(history.prefix(30))
        }
        
        if todayIntake >= goal && !isOverHydrated {
            streak += 1
        } else {
            streak = 0
        }
        
        todayIntake = 0
        todayEntries = []
        showOverhydrationAlert = false
        
        save()
        WKInterfaceDevice.current().play(.notification)
    }
    
    func setGoal(_ newGoal: Int) {
        goal = max(500, min(5000, newGoal))
        save()
    }
    
    func setGoalBasedOnWeight(weight: Int) {
        let calculated = weight * 35
        goal = max(1500, min(5000, calculated))
        self.weight = weight
        saveWeight()
        save()
    }
    
    func updateWeight(_ newWeight: Int) {
        weight = max(30, min(300, newWeight))
        saveWeight()
        setGoalBasedOnWeight(weight: weight)
    }
    
    // MARK: - Day Management
    private func checkNewDay() {
        let lastDate = UserDefaults.standard.object(forKey: lastDateKey) as? Date
        let today = Date()
        
        if let lastDate = lastDate {
            if !Calendar.current.isDate(lastDate, inSameDayAs: today) {
                resetDay()
            }
        }
        
        UserDefaults.standard.set(today, forKey: lastDateKey)
    }
    
    // MARK: - Persistence
    func save() {  // ← Changed from private to internal (accessible)
        UserDefaults.standard.set(todayIntake, forKey: intakeKey)
        UserDefaults.standard.set(goal, forKey: goalKey)
        UserDefaults.standard.set(streak, forKey: streakKey)
        UserDefaults.standard.set(reminderInterval, forKey: reminderIntervalKey)
        
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
        
        if let encoded = try? JSONEncoder().encode(todayEntries) {
            UserDefaults.standard.set(encoded, forKey: entriesKey)
        }
    }
    
    private func load() {
        todayIntake = UserDefaults.standard.integer(forKey: intakeKey)
        
        let savedGoal = UserDefaults.standard.integer(forKey: goalKey)
        if savedGoal > 0 {
            goal = savedGoal
        }
        
        streak = UserDefaults.standard.integer(forKey: streakKey)
        
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([DailyRecord].self, from: data) {
            history = decoded
        } else {
            history = []
        }
        
        if let data = UserDefaults.standard.data(forKey: entriesKey),
           let decoded = try? JSONDecoder().decode([DrinkEntry].self, from: data) {
            todayEntries = decoded
        } else {
            todayEntries = []
        }
    }
    
    private func loadReminderInterval() {
        if let saved = UserDefaults.standard.string(forKey: reminderIntervalKey) {
            reminderInterval = saved
        }
    }
    
    private func saveWeight() {
        UserDefaults.standard.set(weight, forKey: weightKey)
    }
    
    private func loadWeight() {
        let savedWeight = UserDefaults.standard.integer(forKey: weightKey)
        if savedWeight > 0 {
            weight = savedWeight
        }
    }
    
    // MARK: - Notifications
    private func sendGoalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🎉 Goal Reached!"
        content.body = "You hit your hydration goal! Great job! 💪"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "goalReached-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
    
    private func sendOverhydrationWarning() {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Hydration Alert"
        content.body = "You've consumed \(todayIntake)ml today. This exceeds the safe daily limit of \(maxSafeWaterPerDay)ml for your weight (\(weight)kg). Please be careful! 🚨"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "overhydration-\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
    
    func scheduleReminders() {
        guard reminderSettings.enabled else { return }
        
        let intervalSeconds = getIntervalInSeconds(reminderInterval)
        
        let content = UNMutableNotificationContent()
        content.title = "💧 Time to Hydrate"
        content.body = "Drink some water to stay healthy! 💪"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: intervalSeconds, repeats: true)
        let request = UNNotificationRequest(
            identifier: "hydrationReminder",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
    
    func removeReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    private func getIntervalInSeconds(_ interval: String) -> TimeInterval {
        switch interval {
        case "1 hour":
            return 3600
        case "2 hours":
            return 7200
        case "3 hours":
            return 10800
        case "4 hours":
            return 14400
        default:
            return 3600
        }
    }
    
    func updateReminderInterval(_ newInterval: String) {
        reminderInterval = newInterval
        save()
        if reminderSettings.enabled {
            removeReminders()
            scheduleReminders()
        }
    }
    
    // MARK: - Debug
    func printStats() {
        print("💧 Hydration Stats:")
        print("  Today: \(todayIntake)ml")
        print("  Goal: \(goal)ml")
        print("  Weight: \(weight)kg")
        print("  Max Safe Daily: \(maxSafeWaterPerDay)ml")
        print("  Progress: \(Int(progress * 100))%")
        print("  Streak: \(streak)")
        print("  Total Days: \(totalDays)")
        print("  Avg Intake: \(averageIntake)ml")
        print("  Best Day: \(bestDay?.intake ?? 0)ml")
        print("  Completion Rate: \(Int(completionRate * 100))%")
        print("  Reminder Interval: \(reminderInterval)")
    }
}
