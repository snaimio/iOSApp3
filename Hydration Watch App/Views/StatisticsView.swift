//  =====================================
//  StatisticsView.swift
//  Hydration Watch App
//  Created by Sheikh Naim on 2026-06-21.
//  =====================================

// Import SwiftUI framework for building the user interface
// SwiftUI provides ScrollView, LazyVGrid, Text, etc.

import SwiftUI

// MARK: - StatisticsView
// This screen displays all the user's hydration statistics and progress
// It shows summary stats, best day, weekly progress chart, and total intake
// Users can see their overall performance at a glance

struct StatisticsView: View {
    
    // MARK: - Properties
    
    // Access to the HydrationManager (shared data and logic)
    // @EnvironmentObject allows this view to use the same manager instance
    
    @EnvironmentObject var manager: HydrationManager
    
    // MARK: - Body
    
    var body: some View {
        
        // ScrollView allows the content to scroll if it doesn't fit on screen
        // This is important because there's a lot of information to display
        
        ScrollView {
            
            // VStack arranges all child views vertically (top to bottom)
            
            VStack(spacing: 12) {
                
                // MARK: - Title
                
                Text("📊 Stats")
                    .font(.headline)
                    .padding(.top, 4)  // Small padding from top
                
                // MARK: - Stats Grid
                
                // LazyVGrid creates a grid layout with two columns
                // Lazy means views are created only when needed (performance)
                // GridItem(.flexible()) makes each column take equal width
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),  // First column
                    GridItem(.flexible())   // Second column
                ], spacing: 8) {  // 8 points between grid items
                    
                    // Four stat cards displayed in a 2x2 grid
                    
                    StatCard(
                        value: "\(manager.totalDays)",   // Total days tracked
                        label: "Total Days",
                        icon: "calendar",
                        color: .blue
                    )
                    
                    StatCard(
                        value: "\(manager.streak)",      // Current streak
                        label: "Current Streak",
                        icon: "flame.fill",
                        color: .orange
                    )
                    
                    StatCard(
                        value: "\(manager.goal)ml",      // Daily goal
                        label: "Daily Goal",
                        icon: "target",
                        color: .green
                    )
                    
                    StatCard(
                        value: "\(manager.averageIntake)ml",  // Average intake
                        label: "Avg Intake",
                        icon: "drop.fill",
                        color: .cyan
                    )
                }
                
                // MARK: - Best Day
                
                // Only show if there is at least one day of history
                // Optional binding: if let best = manager.bestDay
                
                if let best = manager.bestDay {
                    
                    // VStack for best day section
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("🏆 Best Day")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        // HStack displays the best day details horizontally
                        
                        HStack {
                            Text(best.formattedDate)  // Date of best day
                                .font(.system(size: 13, weight: .medium))
                            Spacer()
                            Text("\(best.intake) ml")  // Amount consumed
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.green)
                            Text("\(Int(best.progress * 100))%")  // Percentage of goal
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 8)  // Horizontal padding
                        .padding(.vertical, 6)    // Vertical padding
                        .background(
                            RoundedRectangle(cornerRadius: 8)  // Rounded background
                                .fill(Color.green.opacity(0.08))  // Light green tint
                        )
                    }
                }
                
                // MARK: - Weekly Progress
                
                // VStack for the weekly progress bar chart
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("📈 Weekly Progress")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    // HStack displays the bars horizontally
                    // Each bar represents one day of the week
                    
                    HStack(alignment: .bottom, spacing: 6) {
                        
                        // ForEach loops through the weeklyData array
                        // Each item is a tuple: (day, progress)
                        
                        ForEach(manager.weeklyData, id: \.0) { day, progress in
                            
                            // VStack for each day's bar
                            
                            VStack(spacing: 2) {
                                
                                // The bar: a rounded rectangle
                                // Height is proportional to progress (up to 50 points)
                                // Color is green if goal met, blue if not
                                
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(progress >= 1.0 ? Color.green : Color.blue)
                                    .frame(width: 18, height: max(8, CGFloat(progress) * 50))
                                
                                // Day label (M, T, W, T, F, S, S)
                                
                                Text(day)
                                    .font(.system(size: 7))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .frame(height: 70)  // Fixed height for the chart
                    .frame(maxWidth: .infinity)  // Stretch to fill width
                    .padding(.vertical, 4)  // Vertical padding
                    .background(
                        RoundedRectangle(cornerRadius: 10)  // Rounded background
                            .fill(Color.gray.opacity(0.05))  // Very light gray
                    )
                }
                
                // MARK: - Total Intake
                
                // VStack for total intake summary
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("💧 Total Intake")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    // HStack displays total intake and days met goal
                    
                    HStack {
                        Text("\(manager.totalIntakeAllTime) ml")  // Total all time
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.blue)
                        Spacer()
                        Text("\(manager.daysMetGoal) days met goal")  // Days with 100%+ progress
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 8)  // Horizontal padding
                    .padding(.vertical, 6)    // Vertical padding
                    .background(
                        RoundedRectangle(cornerRadius: 8)  // Rounded background
                            .fill(Color.blue.opacity(0.06))  // Light blue tint
                    )
                }
            }
            .padding(.horizontal, 12)  // Horizontal padding for the VStack
            .padding(.vertical, 4)     // Vertical padding for the VStack
        }
    }
}

// MARK: - Stat Card
// This is a reusable component for displaying statistics in a card layout
// Used in the grid to show Total Days, Streak, Goal, and Avg Intake

struct StatCard: View {
    
    // MARK: - Properties
    
    let value: String   // The stat value (e.g., "5", "3", "3000ml")
    let label: String   // The stat label (e.g., "Total Days", "Current Streak")
    let icon: String    // SF Symbol name (e.g., "calendar", "flame.fill")
    let color: Color    // The color of the card (Blue, Orange, Green, Cyan)
    
    // MARK: - Body
    
    var body: some View {
        
        // VStack arranges icon, value, and label vertically
        // spacing: 2 provides a small gap between elements
        
        VStack(spacing: 2) {
            
            // Icon at the top
            
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            
            // Value in bold, rounded font
            
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
            
            // Label in smaller gray text
            // multilineTextAlignment(.center) centers text if it wraps
            
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)  // Stretch to fill available width
        .padding(.vertical, 8)  // Vertical padding
        .background(
            RoundedRectangle(cornerRadius: 12)  // Rounded rectangle background
                .fill(Color.gray.opacity(0.06))  // Very light gray
        )
    }
}
