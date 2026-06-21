//  =====================================
//  SettingsView.swift
//  Hydration Watch App
//  Created by Sheikh Naim on 2026-06-18.
//  =====================================

// Import SwiftUI framework for building the user interface
// SwiftUI provides List, Section, Toggle, Stepper, Button, etc.

import SwiftUI

// MARK: - SettingsView
// This screen allows users to customize their app settings
// Users can adjust daily goal, body weight, reminders, and reset the day

struct SettingsView: View {
    
    // MARK: - Properties
    
    // Access to the HydrationManager (shared data and logic)
    
    @EnvironmentObject var manager: HydrationManager
    
    // Array of available reminder interval options
    
    let reminderTimes = ["1 hour", "2 hours", "3 hours", "4 hours"]
    
    // State variables to control sheet presentations
    
    @State private var showingReminderPicker = false  // Shows reminder picker sheet
    @State private var showingWeightPicker = false    // Shows weight picker sheet
    
    // MARK: - Body
    
    var body: some View {
        
        // List is a scrollable container that organizes content into sections
        // It's the standard way to display settings on watchOS
        
        List {
            
            // MARK: - Daily Goal Section
            
            Section {
                
                // HStack arranges goal controls horizontally
                // Users can adjust the goal using minus/plus buttons
                
                HStack {
                    Text("Goal")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()  // Pushes content to edges
                    
                    // Minus button: decreases goal by 100ml
                    // Only works if goal > 1000
                    
                    Button(action: { if manager.goal > 1000 { manager.goal -= 100 } }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.plain)
                    
                    // Display current goal value
                    
                    Text("\(manager.goal)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .frame(minWidth: 45)  // Fixed width for consistent layout
                    
                    // Plus button: increases goal by 100ml
                    // Only works if goal < 5000
                    
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
                .padding(.vertical, 2)  // Vertical padding
                
            } header: {
                Text("Daily Goal")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // MARK: - Body Weight Section
            
            Section {
                
                // Button that opens the weight picker sheet
                // Shows current weight with a chevron indicating it's tappable
                
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
                            
                            Image(systemName: "chevron.right")  // Chevron indicates tappable
                                .font(.system(size: 10))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 4)  // Vertical padding for touch target
                }
                .buttonStyle(.plain)  // Removes default button styling
                
                // Sheet that appears when showingWeightPicker is true
                // Allows user to select their body weight
                
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
            
            // MARK: - Reminder Settings Section
            
            Section {
                
                // Toggle switch to enable/disable reminders
                
                Toggle("Reminders", isOn: $manager.reminderSettings.enabled)
                    .font(.system(size: 14, weight: .medium))
                    .onChange(of: manager.reminderSettings.enabled) { oldValue, newValue in
                        
                        // When toggle changes, schedule or remove reminders
                        
                        if newValue {
                            Task { @MainActor in
                                manager.scheduleReminders()  // Start reminders
                            }
                        } else {
                            Task { @MainActor in
                                manager.removeReminders()   // Stop reminders
                            }
                        }
                    }
                
                // Show reminder interval picker only if reminders are enabled
                
                if manager.reminderSettings.enabled {
                    
                    // Button that opens the reminder interval picker
                    
                    Button(action: { showingReminderPicker = true }) {
                        HStack {
                            Text("Every")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Text(manager.reminderInterval)  // Current interval
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.blue)
                                
                                Image(systemName: "chevron.right")  // Chevron indicates tappable
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                    
                    // Sheet that appears when showingReminderPicker is true
                    // Allows user to select reminder interval
                    
                    .sheet(isPresented: $showingReminderPicker) {
                        ReminderPickerView(manager: manager, isPresented: $showingReminderPicker)
                    }
                }
                
            } header: {
                Text("Reminders")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            // MARK: - Reset Day Section
            
            Section {
                
                // Button to reset the current day
                // Saves today's data to history and starts fresh
                
                Button(action: { manager.resetDay() }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise.circle.fill")  // Reset icon
                            .foregroundColor(.orange)
                        Text("Reset Today")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)  // Center the content
                }
            }
        }
        .listStyle(.carousel)  // Carousel style looks good on watchOS
    }
}

// MARK: - Weight Picker View
// This sheet allows users to select their body weight from a list

struct WeightPickerView: View {
    
    // MARK: - Properties
    
    @ObservedObject var manager: HydrationManager  // Shared data
    @Binding var isPresented: Bool  // Controls sheet dismissal
    
    // Array of weights from 30kg to 200kg
    let weights = Array(30...200)
    
    // MARK: - Body
    
    var body: some View {
        
        // List displays all weight options
        
        List {
            ForEach(weights, id: \.self) { weight in
                
                // Each weight is a button that updates the weight and dismisses the sheet
                
                Button(action: {
                    Task { @MainActor in
                        manager.updateWeight(weight)  // Update weight in manager
                        isPresented = false  // Dismiss the sheet
                    }
                }) {
                    HStack {
                        Text("\(weight) kg")
                            .font(.system(size: 14, weight: .medium))
                        
                        Spacer()
                        
                        // Show checkmark if this is the currently selected weight
                        
                        if manager.weight == weight {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("Weight")  // Title shown at the top
    }
}

// MARK: - Reminder Picker View
// This sheet allows users to select how often they want reminders

struct ReminderPickerView: View {
    
    // MARK: - Properties
    
    @ObservedObject var manager: HydrationManager  // Shared data
    @Binding var isPresented: Bool  // Controls sheet dismissal
    
    // Available reminder interval options
    
    let reminderTimes = ["1 hour", "2 hours", "3 hours", "4 hours"]
    
    // MARK: - Body
    
    var body: some View {
        
        // List displays all reminder interval options
        
        List {
            ForEach(reminderTimes, id: \.self) { time in
                
                // Each option is a button that updates the interval and dismisses the sheet
                
                Button(action: {
                    Task { @MainActor in
                        manager.updateReminderInterval(time)  // Update interval in manager
                        isPresented = false  // Dismiss the sheet
                    }
                }) {
                    HStack {
                        Text(time)
                            .font(.system(size: 14, weight: .medium))
                        
                        Spacer()
                        
                        // Show checkmark if this is the currently selected interval
                        
                        if manager.reminderInterval == time {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
        }
        .navigationTitle("Reminder Interval")  // Title shown at the top
    }
}
