//  =====================================
//  HomeView.swift
//  Hydration Watch App
//  Created by Sheikh Naim on 2026-06-18.
//  =====================================

// Import SwiftUI framework for building the user interface
// SwiftUI provides all the UI components like VStack, Text, Button, ProgressView, etc.

import SwiftUI

// MARK: - HomeView
// This is the main dashboard screen of the app
// It displays the progress ring, water intake stats, and quick add buttons
// The user can log water, undo entries, and see their daily progress at a glance

struct HomeView: View {
    
    // MARK: - Properties
    
    // Access to the HydrationManager (shared data and logic)
    // @EnvironmentObject allows this view to use the same manager instance
    
    @EnvironmentObject var manager: HydrationManager
    
    // State variable to control whether the custom log sheet is shown
    // When this becomes true, the sheet slides up from the bottom
    
    @State private var showSheet = false
    
    // State variable to control whether the undo alert is shown
    // When this becomes true, an alert popup appears asking for confirmation
    
    @State private var showUndoAlert = false
    
    // MARK: - Body
    
    var body: some View {
        
        // VStack arranges all child views vertically (top to bottom)
        // spacing: 0 means no extra space between views (we control spacing manually)
        
        VStack(spacing: 0) {
            
            // MARK: - Content (Fits on Screen)
            
            // Inner VStack with spacing: 6 between each element
            
            VStack(spacing: 6) {
                
                // MARK: - Header - App Name
                
                // HStack arranges the app name and icon horizontally
                // Blue color matches the app's branding
                
                HStack {
                    HStack(spacing: 5) {
                        Image(systemName: "drop.fill")  // Water drop icon
                            .font(.system(size: 17))
                            .foregroundColor(.blue)
                        Text("Hydrate")  // App name
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                    Spacer()  // Pushes the header to the left
                }
                .padding(.horizontal, 4)  // Add horizontal padding
                .padding(.top, 4)  // Add top padding
                
                // MARK: - Progress Ring with Left/Right Buttons
                
                // HStack arranges the Undo button, Progress Ring, and Custom button horizontally
                
                HStack(spacing: 10) {
                    
                    // MARK: - LEFT: Undo Button (Yellow)
                    
                    // Button that allows the user to undo the last entry
                    // Only works if there are entries to undo
                    // Yellow color makes it stand out as an action button
                    
                    Button(action: {
                        if !manager.todayEntries.isEmpty {  // Only if there are entries
                            showUndoAlert = true  // Show confirmation alert
                        }
                    }) {
                        VStack(spacing: 3) {
                            Image(systemName: "arrow.uturn.backward.circle.fill")  // Undo icon
                                .font(.system(size: 26))
                                .foregroundColor(manager.todayEntries.isEmpty ? .gray.opacity(0.3) : .yellow)
                            Text("Undo")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(manager.todayEntries.isEmpty ? .gray.opacity(0.3) : .yellow)
                        }
                        .frame(width: 44)  // Fixed width for consistent layout
                    }
                    .buttonStyle(.plain)  // Removes default button styling
                    .disabled(manager.todayEntries.isEmpty)  // Disable if no entries
                    
                    // MARK: - CENTER: Progress Ring
                    
                    // VStack contains the ring and status text below it
                    
                    VStack(spacing: 6) {
                        
                        // ZStack layers the ring and center text on top of each other
                        
                        ZStack {
                            
                            // Background ring (gray outline)
                            // This creates the empty circle behind the progress
                            
                            Circle()
                                .stroke(Color.gray.opacity(0.15), lineWidth: 7)
                                .frame(width: 72, height: 72)
                            
                            // Progress ring (fills based on progress)
                            // trim(from: 0, to: progress) shows only a portion of the circle
                            // Color changes based on state: Purple, Green, or Red
                            
                            Circle()
                                .trim(from: 0, to: min(manager.progress, 1.0))
                                .stroke(
                                    manager.isOverHydrated ? Color.red : (manager.progress >= 1.0 ? Color.green : Color.purple),
                                    style: StrokeStyle(lineWidth: 7, lineCap: .round)
                                )
                                .frame(width: 72, height: 72)
                                .rotationEffect(.degrees(-90))  // Start from top (12 o'clock)
                                .animation(.spring(response: 0.5), value: manager.progress)  // Smooth animation
                            
                            // Center text: shows today's intake in ml
                            
                            VStack(spacing: 0) {
                                Text("\(manager.todayIntake)")
                                    .font(.system(size: 17, weight: .bold, design: .rounded))
                                    .foregroundColor(manager.isOverHydrated ? .red : (manager.progress >= 1.0 ? .green : .purple))
                                Text("ml")
                                    .font(.system(size: 8))
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // MARK: - Status below ring
                        
                        // Displays different status messages based on current state
                        // Orange color for "remaining", Green for "Done!", Red for "Over"
                        
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
                    
                    // MARK: - RIGHT: Custom Log Button (Pink)
                    
                    // Button that opens the custom log sheet
                    // Pink color differentiates it from other buttons
                    
                    Button(action: { showSheet = true }) {  // Show the sheet when tapped
                        VStack(spacing: 3) {
                            Image(systemName: "plus.circle.fill")  // Plus icon
                                .font(.system(size: 26))
                                .foregroundColor(.pink)
                            Text("Custom")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.pink)
                        }
                        .frame(width: 44)  // Fixed width for consistent layout
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 4)  // Horizontal padding for the HStack
                
                // MARK: - Goal + Streak
                
                // HStack displays the daily goal and streak on the same line
                // Goal is teal color, Streak is indigo color
                
                HStack(spacing: 8) {
                    HStack(spacing: 3) {
                        Image(systemName: "target")  // Target icon for goal
                            .font(.system(size: 9))
                            .foregroundColor(.teal)
                        Text("\(manager.goal) ml")
                            .font(.system(size: 10))
                            .foregroundColor(.teal)
                    }
                    
                    Spacer()  // Pushes goal to left and streak to right
                    
                    HStack(spacing: 3) {
                        Image(systemName: "flame.fill")  // Flame icon for streak
                            .font(.system(size: 9))
                            .foregroundColor(.indigo)
                        Text("\(manager.streak) days")
                            .font(.system(size: 10))
                            .foregroundColor(.indigo)
                    }
                }
                .padding(.horizontal, 6)  // Horizontal padding
                .padding(.vertical, 3)  // Vertical padding
                
                // MARK: - Quick Add Buttons
                
                // HStack arranges the three quick add buttons horizontally
                // Each button has a different color: Mint, Green, Orange
                
                HStack(spacing: 6) {
                    QuickAdd(amount: 250, color: .mint)   // Small amount
                    QuickAdd(amount: 500, color: .green)  // Medium amount
                    QuickAdd(amount: 1000, color: .orange) // Large amount
                }
                .padding(.horizontal, 2)  // Small horizontal padding
                
                Spacer(minLength: 8)  // Pushes content up and adds bottom spacing
            }
            .padding(.horizontal, 8)  // Overall horizontal padding
            .padding(.vertical, 4)  // Overall vertical padding
        }
        
        // MARK: - Sheet Modifier
        
        // .sheet presents a modal view (popup) from the bottom of the screen
        // The AddWaterView appears when showSheet is true
        
        .sheet(isPresented: $showSheet) {
            AddWaterView()  // The view to show as a sheet
        }
        
        // MARK: - Alert Modifiers
        
        // Alert shown when the user taps "Undo"
        // Asks for confirmation before undoing the last entry
        
        .alert("Undo Last Entry", isPresented: $showUndoAlert) {
            Button("Cancel", role: .cancel) { }  // Cancel button (does nothing)
            Button("Undo", role: .destructive) {  // Destructive action (red text)
                manager.undoLastEntry()  // Undo the last entry
            }
        } message: {
            
            // Shows the details of the entry being undone
            
            if let last = manager.todayEntries.last {
                Text("Remove the last entry of \(last.amount) ml logged at \(last.formattedTime)?")
            } else {
                Text("No entries to undo.")
            }
        }
        
        // Alert shown when overhydration is detected
        // Warns the user about excessive water intake
        
        .alert("⚠️ Hydration Alert", isPresented: $manager.showOverhydrationAlert) {
            Button("OK") { }  // Simple confirmation button
        } message: {
            Text("You've exceeded the safe daily limit of \(manager.maxSafeWaterPerDay)ml for your weight (\(manager.weight)kg). Please stop drinking and consult a doctor if you feel unwell.")
        }
    }
}

// MARK: - Quick Add Button
// This is a reusable component for the quick add buttons
// Each button has a specific amount and color

struct QuickAdd: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var manager: HydrationManager  // Shared data
    
    let amount: Int   // How many ml to add (e.g., 250, 500, 1000)
    let color: Color  // The color of the button
    
    // MARK: - Body
    
    var body: some View {
        
        // Button that adds the specified amount of water
        
        Button(action: {
            manager.addWater(amount)  // Add water to today's intake
            WKInterfaceDevice.current().play(.click)  // Play click haptic feedback
        }) {
            
            // VStack inside the button: icon on top, text below
            
            VStack(spacing: 2) {
                Image(systemName: "drop.fill")  // Water drop icon
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                Text("+\(amount)")  // Display the amount (e.g., "+250")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            .frame(height: 40)  // Fixed height for consistent sizing
            .frame(maxWidth: .infinity)  // Stretch to fill available width
            .background(
                RoundedRectangle(cornerRadius: 10)  // Rounded rectangle background
                    .fill(color)  // Fill with the specified color
                    .shadow(color: color.opacity(0.3), radius: 3)  // Subtle shadow
            )
        }
        .buttonStyle(.plain)  // Removes default button styling
    }
}
