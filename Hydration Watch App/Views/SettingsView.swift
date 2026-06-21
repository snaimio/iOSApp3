//
//  SettingsView.swift
//  Hydration Watch App
//
//  Created by Sheikh Naim on 2026-06-18.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var manager: HydrationManager
    
    // Reminder time options
    let reminderTimes = ["1 hour", "2 hours", "3 hours", "4 hours"]
    @State private var showingReminderPicker = false
    @State private var showingWeightPicker = false
    
    var body: some View {
        List {
            // MARK: - Daily Goal
            Section {
                HStack {
                    Text("Goal")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button(action: { if manager.goal > 1000 { manager.goal -= 100 } }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                    
                    Text("\(manager.goal)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .frame(minWidth: 45)
                    
                    Button(action: { if manager.goal < 5000 { manager.goal += 100 } }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .buttonStyle(.plain)
                    
                    Text("ml")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 2)
            } header: {
                Text("Daily Goal")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // MARK: - Body Weight
            Section {
                Button(action: { showingWeightPicker = true }) {
                    HStack {
                        Text("Weight")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Spacer()
                        
                        HStack(spacing: 4) {
                            Text("\(manager.weight) kg")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.blue)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
                .sheet(isPresented: $showingWeightPicker) {
                    WeightPickerView(manager: manager, isPresented: $showingWeightPicker)
                }
            } header: {
                Text("Body Weight")
                    .font(.caption)
                    .foregroundColor(.gray)
            } footer: {
                Text("Used to calculate safe hydration limits")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            // MARK: - Reminder Settings
            Section {
                Toggle("Reminders", isOn: $manager.reminderSettings.enabled)
                    .font(.system(size: 14, weight: .medium))
                    .onChange(of: manager.reminderSettings.enabled) { oldValue, newValue in
                        if newValue {
                            Task { @MainActor in
                                manager.scheduleReminders()
                            }
                        } else {
                            Task { @MainActor in
                                manager.removeReminders()
                            }
                        }
                    }
                
                if manager.reminderSettings.enabled {
                    Button(action: { showingReminderPicker = true }) {
                        HStack {
                            Text("Every")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Text(manager.reminderInterval)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.blue)
                                
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    .sheet(isPresented: $showingReminderPicker) {
                        ReminderPickerView(manager: manager, isPresented: $showingReminderPicker)
                    }
                }
            } header: {
                Text("Reminders")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // MARK: - Reset Day
            Section {
                Button(action: { manager.resetDay() }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .foregroundColor(.orange)
                        Text("Reset Today")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
        .listStyle(.carousel)
    }
}

// MARK: - Weight Picker View
struct WeightPickerView: View {
    @ObservedObject var manager: HydrationManager
    @Binding var isPresented: Bool
    
    let weights = Array(30...200)
    
    var body: some View {
        List {
            ForEach(weights, id: \.self) { weight in
                Button(action: {
                    Task { @MainActor in
                        manager.updateWeight(weight)
                        isPresented = false
                    }
                }) {
                    HStack {
                        Text("\(weight) kg")
                            .font(.system(size: 14, weight: .medium))
                        
                        Spacer()
                        
                        if manager.weight == weight {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("Weight")
    }
}

// MARK: - Reminder Picker View
struct ReminderPickerView: View {
    @ObservedObject var manager: HydrationManager
    @Binding var isPresented: Bool
    
    let reminderTimes = ["1 hour", "2 hours", "3 hours", "4 hours"]
    
    var body: some View {
        List {
            ForEach(reminderTimes, id: \.self) { time in
                Button(action: {
                    Task { @MainActor in
                        manager.updateReminderInterval(time)
                        isPresented = false
                    }
                }) {
                    HStack {
                        Text(time)
                            .font(.system(size: 14, weight: .medium))
                        
                        Spacer()
                        
                        if manager.reminderInterval == time {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("Reminder Interval")
    }
}
