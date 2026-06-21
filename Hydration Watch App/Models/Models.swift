//  =====================================
//  Models.swift
//  Hydration Watch App
//  Created by Sheikh Naim on 2026-06-18.
//  =====================================

// Import Foundation framework for basic Swift functionality
// This gives us access to Date, UUID, and Codable protocols

import Foundation

// MARK: - DailyRecord Model
// This struct represents a single day's hydration record
// It stores all the data for one complete day
// Identifiable: Each record can be uniquely identified (for SwiftUI lists)
// Codable: Can be saved to and loaded from UserDefaults

struct DailyRecord: Identifiable, Codable {
    
    // Unique identifier for each record (automatically generated)
    
    var id = UUID() // UUID creates a unique random ID
    var date: Date  // The date this record represents
    var intake: Int // Total water consumed on this day (in milliliters)
    var goal: Int    // The daily goal set for this day
    
    // Computed property: calculates progress as a percentage
    // Returns a value between 0.0 and 1.0
    // Example: intake = 2500, goal = 3000 → progress = 0.83 (83%)
    
    var progress: Double {
        guard goal > 0 else { return 0 }  // Prevent division by zero
        return min(1.0, Double(intake) / Double(goal))  // Cap at 1.0 (100%)
    }
    
    // Computed property: formats the date for display
    // Example: June 21, 2024 → "Jun 21"
    
    var formattedDate: String {
        let formatter = DateFormatter()  // Create a date formatter
        formatter.dateFormat = "MMM d"   // Set format: "Jun 21"
        return formatter.string(from: date)  // Convert date to string
    }
}

// MARK: - DrinkEntry Model
// This struct represents a single drink log entry
// Each time the user logs water, a DrinkEntry is created

struct DrinkEntry: Identifiable, Codable {
   
    var id = UUID()  // Unique identifier for each entry
    var amount: Int // Amount of water consumed in this entry (in milliliters)
    var time: Date  // Time when this entry was logged
    
    // Computed property: formats the time for display
    // Example: 3:45 PM → "3:45 PM"
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"  // "h" = 12-hour format, "mm" = minutes, "a" = AM/PM
        return formatter.string(from: time)
    }
}

// MARK: - ReminderSettings Model
// This struct stores the user's reminder preferences

struct ReminderSettings: Codable {
   
    // Whether reminders are enabled or disabled
    // Default is true (enabled)
    
    var enabled: Bool = true
}

// MARK: - AppTheme Enum
// This enum defines the available app themes
// Raw values are strings for easy saving

enum AppTheme: String, Codable {
    case light = "Light"    // Light mode theme
    case dark = "Dark"      // Dark mode theme
    case system = "System"  // Follow system setting
}
