//
//  Models.swift
//  Hydration Watch App
//
//  Created by Sheikh Naim on 2026-06-18.
//

import Foundation

struct DailyRecord: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var intake: Int
    var goal: Int
    
    var progress: Double {
        guard goal > 0 else { return 0 }
        return min(1.0, Double(intake) / Double(goal))
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

struct DrinkEntry: Identifiable, Codable {
    var id = UUID()
    var amount: Int
    var time: Date
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: time)
    }
}

struct ReminderSettings: Codable {
    var enabled: Bool = true
}

enum AppTheme: String, Codable {
    case light, dark, system
}
