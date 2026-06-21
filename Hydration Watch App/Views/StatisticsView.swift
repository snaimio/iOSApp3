//
//  StatisticsView.swift
//  Hydration Watch App
//
//  Created by Sheikh Naim on 2026-06-21.
//

import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var manager: HydrationManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Title
                Text("📊 Stats")
                    .font(.headline)
                    .padding(.top, 4)
                
                // Stats Grid
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 8) {
                    StatCard(
                        value: "\(manager.totalDays)",
                        label: "Total Days",
                        icon: "calendar",
                        color: .blue
                    )
                    
                    StatCard(
                        value: "\(manager.streak)",
                        label: "Current Streak",
                        icon: "flame.fill",
                        color: .orange
                    )
                    
                    StatCard(
                        value: "\(manager.goal)ml",
                        label: "Daily Goal",
                        icon: "target",
                        color: .green
                    )
                    
                    StatCard(
                        value: "\(manager.averageIntake)ml",
                        label: "Avg Intake",
                        icon: "drop.fill",
                        color: .cyan
                    )
                }
                
                // Best Day
                if let best = manager.bestDay {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("🏆 Best Day")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        HStack {
                            Text(best.formattedDate)
                                .font(.system(size: 13, weight: .medium))
                            Spacer()
                            Text("\(best.intake) ml")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.green)
                            Text("\(Int(best.progress * 100))%")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.green.opacity(0.08))
                        )
                    }
                }
                
                // Weekly Progress
                VStack(alignment: .leading, spacing: 4) {
                    Text("📈 Weekly Progress")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack(alignment: .bottom, spacing: 6) {
                        ForEach(manager.weeklyData, id: \.0) { day, progress in
                            VStack(spacing: 2) {
                                RoundedRectangle(cornerRadius: 3)
                                    .fill(progress >= 1.0 ? Color.green : Color.blue)
                                    .frame(width: 18, height: max(8, CGFloat(progress) * 50))
                                
                                Text(day)
                                    .font(.system(size: 7))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .frame(height: 70)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.05))
                    )
                }
                
                // Total Intake
                VStack(alignment: .leading, spacing: 4) {
                    Text("💧 Total Intake")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text("\(manager.totalIntakeAllTime) ml")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.blue)
                        Spacer()
                        Text("\(manager.daysMetGoal) days met goal")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.blue.opacity(0.06))
                    )
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
            
            Text(label)
                .font(.system(size: 9))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.06))
        )
    }
}
