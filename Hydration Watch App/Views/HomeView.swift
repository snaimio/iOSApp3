//
//  HomeView.swift
//  Hydration Watch App
//
//  Created by Sheikh Naim on 2026-06-18.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var manager: HydrationManager
    @State private var showSheet = false
    @State private var showUndoAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Content (Fits on Screen)
            VStack(spacing: 6) {
                // Header - App Name (Blue - KEPT)
                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 17))
                            .foregroundColor(.blue)
                        Text("Hydrate")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                    Spacer()
                }
                .padding(.horizontal, 4)
                .padding(.top, 4)
                
                // Progress Ring with Left/Right Buttons
                HStack(spacing: 10) {
                    // LEFT: Undo Button (Yellow)
                    Button(action: {
                        if !manager.todayEntries.isEmpty {
                            showUndoAlert = true
                        }
                    }) {
                        VStack(spacing: 3) {
                            Image(systemName: "arrow.uturn.backward.circle.fill")
                                .font(.system(size: 26))
                                .foregroundColor(manager.todayEntries.isEmpty ? .gray.opacity(0.3) : .yellow)
                            Text("Undo")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(manager.todayEntries.isEmpty ? .gray.opacity(0.3) : .yellow)
                        }
                        .frame(width: 44)
                    }
                    .buttonStyle(.plain)
                    .disabled(manager.todayEntries.isEmpty)
                    
                    // CENTER: Progress Ring (Purple when not complete)
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.15), lineWidth: 7)
                                .frame(width: 72, height: 72)
                            
                            Circle()
                                .trim(from: 0, to: min(manager.progress, 1.0))
                                .stroke(
                                    manager.isOverHydrated ? Color.red : (manager.progress >= 1.0 ? Color.green : Color.purple),
                                    style: StrokeStyle(lineWidth: 7, lineCap: .round)
                                )
                                .frame(width: 72, height: 72)
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(response: 0.5), value: manager.progress)
                            
                            VStack(spacing: 0) {
                                Text("\(manager.todayIntake)")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(manager.isOverHydrated ? .red : (manager.progress >= 1.0 ? .green : .purple))
                                Text("ml")
                                    .font(.system(size: 8))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Status below ring (Orange for remaining)
                        if manager.isOverHydrated {
                            Text("⚠️ Over")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.red)
                                .padding(.top, 1)
                        } else if manager.remaining > 0 {
                            Text("\(manager.remaining) ml left")
                                .font(.system(size: 10))
                                .fontWeight(.medium)
                                .foregroundColor(.orange)
                                .padding(.top, 1)
                        } else {
                            Label("Done!", systemImage: "checkmark.circle.fill")
                                .font(.system(size: 10))
                                .fontWeight(.medium)
                                .foregroundColor(.green)
                                .padding(.top, 1)
                        }
                    }
                    
                    // RIGHT: Custom Log Button (Pink)
                    Button(action: { showSheet = true }) {
                        VStack(spacing: 3) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 26))
                                .foregroundColor(.pink)
                            Text("Custom")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.pink)
                        }
                        .frame(width: 44)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 4)
                
                // Goal + Streak (Goal: Teal, Streak: Indigo)
                HStack(spacing: 8) {
                    HStack(spacing: 3) {
                        Image(systemName: "target")
                            .font(.system(size: 9))
                            .foregroundColor(.teal)
                        Text("\(manager.goal) ml")
                            .font(.system(size: 10))
                            .foregroundColor(.teal)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.indigo)
                        Text("\(manager.streak) days")
                            .font(.system(size: 10))
                            .foregroundColor(.indigo)
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                
                // Quick Add Buttons (All Unique Colors)
                HStack(spacing: 6) {
                    QuickAdd(amount: 250, color: .mint)
                    QuickAdd(amount: 500, color: .green)
                    QuickAdd(amount: 1000, color: .orange)
                }
                .padding(.horizontal, 2)
                
                Spacer(minLength: 8)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .sheet(isPresented: $showSheet) {
            AddWaterView()
        }
        .alert("Undo Last Entry", isPresented: $showUndoAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Undo", role: .destructive) {
                manager.undoLastEntry()
            }
        } message: {
            if let last = manager.todayEntries.last {
                Text("Remove the last entry of \(last.amount) ml logged at \(last.formattedTime)?")
            } else {
                Text("No entries to undo.")
            }
        }
        .alert("⚠️ Hydration Alert", isPresented: $manager.showOverhydrationAlert) {
            Button("OK") { }
        } message: {
            Text("You've exceeded the safe daily limit of \(manager.maxSafeWaterPerDay)ml for your weight (\(manager.weight)kg). Please stop drinking and consult a doctor if you feel unwell.")
        }
    }
}

// MARK: - Quick Add Button
struct QuickAdd: View {
    @EnvironmentObject var manager: HydrationManager
    let amount: Int
    let color: Color
    
    var body: some View {
        Button(action: {
            manager.addWater(amount)
            WKInterfaceDevice.current().play(.click)
        }) {
            VStack(spacing: 2) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                Text("+\(amount)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(color)
                    .shadow(color: color.opacity(0.3), radius: 3)
            )
        }
        .buttonStyle(.plain)
    }
}
