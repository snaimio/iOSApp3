//  =====================================
//  RecentLogsView.swift
//  Hydration Watch App
//  Created by Sheikh Naim on 2026-06-21.
//  =====================================

// Import SwiftUI framework for building the user interface
// SwiftUI provides List, VStack, HStack, Text, Image, etc.

import SwiftUI

// MARK: - RecentLogsView
// This screen displays all the water entries logged today
// It shows the most recent entries at the top
// Users can swipe to delete any entry

struct RecentLogsView: View {
    
    // MARK: - Properties
    
    // Access to the HydrationManager (shared data and logic)
    // @EnvironmentObject allows this view to use the same manager instance
    
    @EnvironmentObject var manager: HydrationManager
    
    // MARK: - Body
    
    var body: some View {
        
        // VStack arranges all child views vertically (top to bottom)
        
        VStack(spacing: 6) {
            
            // MARK: - Title
            
            // HStack arranges the title icon and text horizontally
            // Indigo color gives it a unique look (different from other screens)
            
            HStack {
                Image(systemName: "clock.fill")  // Clock icon
                    .foregroundColor(.indigo)
                    .font(.system(size: 16))
                Text("Recent Logs")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.indigo)
                Spacer()  // Pushes the title to the left
            }
            .padding(.horizontal, 12)  // Horizontal padding
            .padding(.top, 2)  // Small top padding
            
            // MARK: - Stats - Colorful Cards
            
            // HStack arranges the three stat cards horizontally
            // Each card has a unique color: Blue, Green, Orange
            
            HStack(spacing: 8) {
                CompactStat(value: "\(manager.todayIntake)", label: "Today", color: .blue)
                CompactStat(value: "\(manager.goal)ml", label: "Goal", color: .green)
                CompactStat(value: "\(manager.remaining)ml", label: "Left", color: .orange)
            }
            .padding(.horizontal, 4)  // Horizontal padding
            
            // MARK: - Entries List
            
            // Check if there are any entries for today
            
            if manager.todayEntries.isEmpty {
                
                // Show empty state when no entries exist
                // Displays a clock icon and helpful messages
                
                VStack(spacing: 8) {
                    Image(systemName: "clock.arrow.circlepath")  // Empty clock icon
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    Text("No logs yet")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("Start logging water today!")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .frame(maxHeight: .infinity)  // Take up available space
                .padding(.top, 20)  // Padding from top
                
            } else {
                
                // Show the list of entries
                // List is a scrollable container that shows each entry as a row
                
                List {
                    
                    // Show the last 3 entries (most recent first)
                    // .reversed() shows newest first
                    // .prefix(3) shows only the 3 most recent entries
                    // This keeps the screen clean and fits without scrolling
                    
                    let entriesToShow = manager.todayEntries.reversed().prefix(3)
                    
                    // ForEach loops through each entry and creates a row
                    
                    ForEach(Array(entriesToShow)) { entry in
                        
                        // HStack arranges the row content horizontally
                        
                        HStack {
                            
                            // Water drop icon (teal color)
                            
                            Image(systemName: "drop.fill")
                                .foregroundColor(.teal)
                                .font(.system(size: 10))
                            
                            // Time the water was logged (e.g., "3:45 PM")
                            
                            Text(entry.formattedTime)
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                            
                            Spacer()  // Pushes time to left and amount to right
                            
                            // Amount in ml (purple color stands out)
                            
                            Text("\(entry.amount) ml")
                                .font(.system(size: 11))
                                .fontWeight(.medium)
                                .foregroundColor(.purple)
                        }
                        .padding(.vertical, 2)  // Vertical padding inside each row
                    }
                    
                    // MARK: - Delete Functionality
                    
                    // .onDelete allows users to swipe left on a row to delete it
                    // The system provides a red "Delete" button
                    
                    .onDelete { indexSet in
                        
                        // indexSet contains the positions of items to delete
                        // We need to convert these to actual indices in the original array
                        // Since we're showing reversed entries, we calculate the original index
                        
                        let indicesToDelete = indexSet.map { index in
                            manager.todayEntries.count - 1 - index
                        }.sorted(by: >)  // Sort in descending order to remove safely
                        
                        // Loop through each index and remove the entry
                        
                        for index in indicesToDelete {
                            let entry = manager.todayEntries[index]  // Get the entry
                            manager.todayIntake -= entry.amount      // Subtract from total
                            manager.todayEntries.remove(at: index)   // Remove from array
                        }
                        
                        // Save the updated data to UserDefaults
                        
                        manager.save()
                        
                        // Play a click haptic for feedback
                        
                        WKInterfaceDevice.current().play(.click)
                    }
                }
                .listStyle(.carousel)  // Carousel style looks good on watchOS
                .frame(height: 110)  // Fixed height for exactly 3 entries
            }
        }
        .padding(.vertical, 4)  // Overall vertical padding for the VStack
    }
}

// MARK: - Compact Stat Card
// This is a reusable component for displaying statistics in a compact card

struct CompactStat: View {
    
    // MARK: - Properties
    
    let value: String   // The stat value (e.g., "1500")
    let label: String   // The stat label (e.g., "Today")
    let color: Color    // The color of the stat (Blue, Green, or Orange)
    
    // MARK: - Body
    
    var body: some View {
        
        // VStack arranges value and label vertically
        
        VStack(spacing: 1) {
            Text(value)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 8))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)  // Stretch to fill available width
        .padding(.vertical, 4)  // Vertical padding
        .background(
            RoundedRectangle(cornerRadius: 8)  // Rounded rectangle background
                .fill(color.opacity(0.1))  // Same color with 10% opacity
        )
    }
}
