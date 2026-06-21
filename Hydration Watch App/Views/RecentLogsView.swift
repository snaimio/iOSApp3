//
//  RecentLogsView.swift
//  Hydration Watch App
//
//  Created by Sheikh Naim on 2026-06-21.
//

import SwiftUI

struct RecentLogsView: View {
    @EnvironmentObject var manager: HydrationManager
    
    var body: some View {
        VStack(spacing: 6) {
            // Title - Unique Color (Indigo)
            HStack {
                Image(systemName: "clock.fill")
                    .foregroundColor(.indigo)
                    .font(.system(size: 16))
                Text("Recent Logs")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.indigo)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 2)
            
            // Stats - Colorful Cards (All Unique)
            HStack(spacing: 8) {
                CompactStat(value: "\(manager.todayIntake)", label: "Today", color: .blue)
                CompactStat(value: "\(manager.goal)ml", label: "Goal", color: .green)
                CompactStat(value: "\(manager.remaining)ml", label: "Left", color: .orange)
            }
            .padding(.horizontal, 4)
            
            // Entries List - Compact to fit 3 entries
            if manager.todayEntries.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "clock.arrow.circlepath")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("No logs yet")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Start logging water today!")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .frame(maxHeight: .infinity)
                .padding(.top, 20)
            } else {
                List {
                    // Show last 3 entries (or all if less than 3)
                    let entriesToShow = manager.todayEntries.reversed().prefix(3)
                    ForEach(Array(entriesToShow)) { entry in
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.teal)
                                .font(.system(size: 10))
                            Text(entry.formattedTime)
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("\(entry.amount) ml")
                                .font(.system(size: 11))
                                .fontWeight(.medium)
                                .foregroundColor(.purple)
                        }
                        .padding(.vertical, 2)
                    }
                    .onDelete { indexSet in
                        // Handle delete
                        let indicesToDelete = indexSet.map { index in
                            manager.todayEntries.count - 1 - index
                        }.sorted(by: >)
                        
                        for index in indicesToDelete {
                            let entry = manager.todayEntries[index]
                            manager.todayIntake -= entry.amount
                            manager.todayEntries.remove(at: index)
                        }
                        
                        manager.save()
                        WKInterfaceDevice.current().play(.click)
                    }
                }
                .listStyle(.carousel)
                .frame(height: 110)  // Fixed height for 3 entries
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Compact Stat Card
struct CompactStat: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 8))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}
