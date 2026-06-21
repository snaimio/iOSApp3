//  =====================================
//  HydrationManager.swift
//  Hydration Watch App
//  Created by Sheikh Naim on 2026-06-18.
//  =====================================

/*
 Import necessary frameworks,
 Foundation: Basic Swift functionality,
 WatchKit: Apple Watch specific features like haptics,
 UserNotifications: For sending reminders and alerts,
 Combine: For reactive programming with @Published,
 SwiftUI: For using Color and other SwiftUI types
 */

import Foundation
import WatchKit
import UserNotifications
import Combine
import SwiftUI

// @MainActor ensures all UI updates happen on the main thread
// This is important for SwiftUI to work properly
// ObservableObject allows SwiftUI views to observe and react to changes

@MainActor
final class HydrationManager: ObservableObject {
    
    // MARK: - Published Properties
    // @Published means when these values change, SwiftUI views will update automatically
    
    @Published var todayIntake = 0  // How much water the user has consumed today (in milliliters)
    @Published var goal = 3000   // The user's daily water intake goal (in milliliters)
    @Published var streak = 0   // How many consecutive days the user has met their goal
    @Published var history: [DailyRecord] = []  // Array of all past daily records (history)
    @Published var todayEntries: [DrinkEntry] = []  // Array of today's individual drink entries
    @Published var reminderSettings = ReminderSettings()    // Settings for reminders (enabled/disabled)
    @Published var reminderInterval: String = "1 hour"  // How often to send reminders (e.g., "1 hour", "2 hours")
    @Published var showOverhydrationAlert = false   // Controls whether the overhydration alert popup is shown
    @Published var weight: Int = 70 // The user's body weight in kilograms (used to calculate safe limits)
    
    // MARK: - Storage Keys
    // These are the keys used to save and load data from UserDefaults
    // Think of them like file names for saving data
    
    private let intakeKey = "todayIntake"          // Key for today's intake
    private let goalKey = "goal"                   // Key for daily goal
    private let historyKey = "history"             // Key for history array
    private let streakKey = "streak"               // Key for streak count
    private let entriesKey = "todayEntries"        // Key for today's entries
    private let lastDateKey = "lastDate"           // Key for last date checked
    private let reminderIntervalKey = "reminderInterval" // Key for reminder interval
    private let weightKey = "userWeight"           // Key for user's weight
    
    // MARK: - Computed Properties
    // These are calculated values that update automatically when dependencies change
    
    // Calculates progress as a percentage (0.0 to 1.0)
    // Example: if todayIntake = 1500 and goal = 3000, progress = 0.5 (50%)
    
    var progress: Double {
        guard goal > 0 else { return 0 }  // Prevent division by zero
        return min(1.0, Double(todayIntake) / Double(goal))  // Cap at 1.0 (100%)
    }
    
    // Calculates how much water is left to reach the goal
    // Example: goal = 3000, todayIntake = 1500 → remaining = 1500
    
    var remaining: Int {
        max(0, goal - todayIntake)  // Never go below 0
    }
    
    // MARK: - Overhydration Limits
    // These properties check if the user has consumed too much water
    
    // Maximum safe water per day based on body weight
    // Formula: 100ml per kg of body weight, capped at 12,000ml (12 liters)
    // Example: 70kg person → 7,000ml max safe daily
    
    var maxSafeWaterPerDay: Int {
        return min(weight * 100, 12000)
    }
    
    // Returns true if today's intake exceeds the safe daily limit
    
    var isOverHydrated: Bool {
        return todayIntake > maxSafeWaterPerDay
    }
    
    // Determines the level of overhydration
    // Returns different levels: normal, slightlyOver, moderatelyOver, severelyOver
    
    var overHydrationLevel: OverHydrationLevel {
        let ratio = Double(todayIntake) / Double(maxSafeWaterPerDay)  // Calculate ratio
        if ratio < 1.0 { return .normal }
        if ratio < 1.2 { return .slightlyOver }
        if ratio < 1.5 { return .moderatelyOver }
        return .severelyOver
    }
    
    // Enum defining different levels of overhydration
    // Each case has associated messages, colors, and emojis for UI display
    
    enum OverHydrationLevel {
        case normal
        case slightlyOver
        case moderatelyOver
        case severelyOver
        
        // Message to display to the user based on the level
        
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
        
        // Color to display based on the level
        
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
        
        // Emoji icon based on the level
        
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
    // These properties calculate various statistics from the history data
    
    // Total number of days tracked in history
    
    var totalDays: Int {
        return history.count
    }
    
    // Average daily intake across all recorded days
    // Example: total intake 10,000ml over 4 days → average = 2,500ml
    
    var averageIntake: Int {
        guard !history.isEmpty else { return 0 }  // Avoid division by zero
        let total = history.reduce(0) { $0 + $1.intake }  // Sum all intakes
        return total / history.count  // Divide by number of days
    }
    
    // Finds the day with the highest water intake
    // Returns the DailyRecord with the maximum intake, or nil if no history
    
    var bestDay: DailyRecord? {
        return history.max(by: { $0.intake < $1.intake })
    }
    
    // Total water consumed across all recorded days
    
    var totalIntakeAllTime: Int {
        return history.reduce(0) { $0 + $1.intake }  // Sum all intakes
    }
    
    // Number of days where the user met their goal
    
    var daysMetGoal: Int {
        return history.filter { $0.progress >= 1.0 }.count  // Count days with 100%+ progress
    }
    
    // Success rate: percentage of days where goal was met
    // Example: 3 days met out of 4 total → 75% completion rate
    
    var completionRate: Double {
        guard !history.isEmpty else { return 0 }
        return Double(daysMetGoal) / Double(history.count)
    }
    
    // MARK: - Weekly Data for Chart
    // Generates data for the weekly progress bar chart
    
    // Returns an array of tuples: (day of week, progress percentage)
    // Example: [("M", 0.8), ("T", 1.0), ("W", 0.6), ...]
    
    var weeklyData: [(String, Double)] {
        let calendar = Calendar.current
        let weekdays = ["M", "T", "W", "T", "F", "S", "S"]  // Day abbreviations
        let today = Date()
        
        // Map each day of the week to its progress
        
        return weekdays.enumerated().map { index, day in
            
            // Calculate date for each day going backwards from today
            
            let date = calendar.date(byAdding: .day, value: -(6 - index), to: today) ?? today
            let startOfDay = calendar.startOfDay(for: date)  // Start of that day
            
            // Find the record for that day
            
            let record = history.first { calendar.isDate($0.date, inSameDayAs: startOfDay) }
            let progress = record?.progress ?? 0  // Use 0 if no record
            return (day, progress)
        }
    }
    
    // MARK: - Init
    // Initializer: runs when the HydrationManager is first created
    
    init() {
        load()                 // Load saved data
        checkNewDay()          // Check if a new day has started
        loadReminderInterval() // Load saved reminder interval
        loadWeight()           // Load saved weight
    }
    
    // MARK: - Core Functions
    // These are the main functions users interact with
    
    // Adds water to today's intake
    // amount: how many milliliters to add (e.g., 250, 500, 1000)
    
    func addWater(_ amount: Int) {
        todayIntake += amount   // Add to today's total

        // Create a new entry with timestamp
        
        todayEntries.append(DrinkEntry(amount: amount, time: Date()))
        
        // Play a click haptic to confirm the action
        
        WKInterfaceDevice.current().play(.click)
        
        // Check if goal is reached (but not overhydrated)
        
        if todayIntake >= goal && !isOverHydrated {
            WKInterfaceDevice.current().play(.success)  // Success haptic
            sendGoalNotification()  // Send notification
        }
        
        // Check if overhydration limit is exceeded
        if isOverHydrated {
            WKInterfaceDevice.current().play(.failure)  // Failure haptic
            sendOverhydrationWarning()  // Send warning notification
            showOverhydrationAlert = true  // Show alert popup
        }
        
        save()  // Save all data to UserDefaults
    }
    
    // Removes the last entry (undo function)
    func undoLastEntry() {
        guard let last = todayEntries.last else { return }  // Make sure there's an entry
        todayEntries.removeLast()   // Remove the last entry from the array
        todayIntake -= last.amount  // Subtract its amount from today's total
        
        if showOverhydrationAlert { // If overhydration alert was shown, reset it
            showOverhydrationAlert = false
        }
        
        save()      // Save after undo
        WKInterfaceDevice.current().play(.click)    // Click haptic for feedback
    }
    
    // Resets the current day
    // Saves today's data to history and starts a new day
    
    func resetDay() {
        
        // Create a record for today and add to history
        
        let record = DailyRecord(date: Date(), intake: todayIntake, goal: goal)
        history.insert(record, at: 0)  // Insert at beginning (newest first)
        
        // Keep only last 30 days to save storage
        
        if history.count > 30 {
            history = Array(history.prefix(30))
        }
        
        // Update streak: increment if goal met, otherwise reset to 0
        
        if todayIntake >= goal && !isOverHydrated {
            streak += 1
        } else {
            streak = 0
        }
        
        // Reset today's values
        
        todayIntake = 0
        todayEntries = []
        showOverhydrationAlert = false
        
        save()  // Save all data
        WKInterfaceDevice.current().play(.notification)  // Notification haptic
    }
    
    // Sets a new daily goal (must be between 500 and 5000ml)
    
    func setGoal(_ newGoal: Int) {
        goal = max(500, min(5000, newGoal))  // Clamp between 500 and 5000
        save()
    }
    
    // Sets goal based on body weight using formula: 35ml per kg
    // Example: 70kg × 35 = 2450ml daily goal
    
    func setGoalBasedOnWeight(weight: Int) {
        let calculated = weight * 35
        goal = max(1500, min(5000, calculated))  // Clamp between 1500 and 5000
        self.weight = weight
        saveWeight()  // Save weight separately
        save()
    }
    
    // Updates user's weight and recalculates goal
    
    func updateWeight(_ newWeight: Int) {
        weight = max(30, min(300, newWeight))  // Clamp between 30 and 300kg
        saveWeight()
        setGoalBasedOnWeight(weight: weight)  // Recalculate goal based on new weight
    }
    
    // MARK: - Day Management
    // Checks if a new day has started and resets if needed
    
    private func checkNewDay() {
        
        // Get the last date the app was opened
        
        let lastDate = UserDefaults.standard.object(forKey: lastDateKey) as? Date
        let today = Date()
        
        // If there was a last date and it's not today, reset the day
        
        if let lastDate = lastDate {
            if !Calendar.current.isDate(lastDate, inSameDayAs: today) {
                resetDay()
            }
        }
        
        // Save today's date for next time
        
        UserDefaults.standard.set(today, forKey: lastDateKey)
    }
    
    // MARK: - Persistence
    // These functions save and load data from UserDefaults
    
    // Saves all data to UserDefaults
    
    func save() {
        
        // Save simple values directly
        
        UserDefaults.standard.set(todayIntake, forKey: intakeKey)
        UserDefaults.standard.set(goal, forKey: goalKey)
        UserDefaults.standard.set(streak, forKey: streakKey)
        UserDefaults.standard.set(reminderInterval, forKey: reminderIntervalKey)
        
        // Encode and save arrays (convert to Data)
        
        if let encoded = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
        
        if let encoded = try? JSONEncoder().encode(todayEntries) {
            UserDefaults.standard.set(encoded, forKey: entriesKey)
        }
    }
    
    // Loads all data from UserDefaults
    
    private func load() {
        
        // Load simple values
        
        todayIntake = UserDefaults.standard.integer(forKey: intakeKey)
        
        // Load goal, use default if not found
        let savedGoal = UserDefaults.standard.integer(forKey: goalKey)
        if savedGoal > 0 {
            goal = savedGoal
        }
        
        streak = UserDefaults.standard.integer(forKey: streakKey)
        
        // Decode and load history array
        
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([DailyRecord].self, from: data) {
            history = decoded
        } else {
            history = []  // Start empty if no data
        }
        
        // Decode and load today's entries
        
        if let data = UserDefaults.standard.data(forKey: entriesKey),
           let decoded = try? JSONDecoder().decode([DrinkEntry].self, from: data) {
            todayEntries = decoded
        } else {
            todayEntries = []  // Start empty if no data
        }
    }
    
    // Load the saved reminder interval
    
    private func loadReminderInterval() {
        if let saved = UserDefaults.standard.string(forKey: reminderIntervalKey) {
            reminderInterval = saved
        }
    }
    
    // Save user's weight to UserDefaults
    
    private func saveWeight() {
        UserDefaults.standard.set(weight, forKey: weightKey)
    }
    
    // Load user's weight from UserDefaults
    
    private func loadWeight() {
        let savedWeight = UserDefaults.standard.integer(forKey: weightKey)
        if savedWeight > 0 {
            weight = savedWeight
        }
    }
    
    // MARK: - Notifications
    // These functions handle sending local notifications
    
    // Send notification when goal is reached
    
    private func sendGoalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🎉 Goal Reached!"
        content.body = "You hit your hydration goal! Great job! 💪"
        content.sound = .default  // Play default notification sound
        
        // Trigger after 1 second
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "goalReached-\(UUID().uuidString)",  // Unique ID
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
    
    // Send warning when overhydration limit is exceeded
    
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
    
    // Schedule regular reminders based on the selected interval
    
    func scheduleReminders() {
        guard reminderSettings.enabled else { return }  // Only if enabled
        
        let intervalSeconds = getIntervalInSeconds(reminderInterval)
        
        let content = UNMutableNotificationContent()
        content.title = "💧 Time to Hydrate"
        content.body = "Drink some water to stay healthy! 💪"
        content.sound = .default
        
        // Repeating trigger at the selected interval
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: intervalSeconds, repeats: true)
        let request = UNNotificationRequest(
            identifier: "hydrationReminder",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }
    
    // Remove all scheduled reminders
    
    func removeReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // Convert interval string to seconds
    
    private func getIntervalInSeconds(_ interval: String) -> TimeInterval {
        switch interval {
        case "1 hour":
            return 3600   // 60 minutes × 60 seconds
        case "2 hours":
            return 7200   // 2 × 3600
        case "3 hours":
            return 10800  // 3 × 3600
        case "4 hours":
            return 14400  // 4 × 3600
        default:
            return 3600   // Default to 1 hour
        }
    }
    
    // Update the reminder interval and reschedule
    
    func updateReminderInterval(_ newInterval: String) {
        reminderInterval = newInterval
        save()
        if reminderSettings.enabled {
            removeReminders()     // Remove old reminders
            scheduleReminders()   // Schedule new ones with updated interval
        }
    }
    
    // MARK: - Debug
    // Helper function to print all statistics for debugging
    
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
