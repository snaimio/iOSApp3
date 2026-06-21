//  =====================================
//  AddWaterView.swift
//  Hydration Watch App
//  Created by Sheikh Naim on 2026-06-21.
//  =====================================

// Import SwiftUI framework for building the user interface
// SwiftUI provides all the UI components like VStack, Text, Button, etc.

import SwiftUI

// MARK: - AddWaterView
// This view appears as a sheet (popup) when the user taps "Custom Log"
// It allows the user to choose a custom amount of water to log
// The user can adjust the amount using presets or +/- buttons

struct AddWaterView: View {
    
    // MARK: - Properties
    
    // Access to the HydrationManager (shared data and logic)
    // @EnvironmentObject allows this view to use the same manager instance
    // that was created in the parent view
    
    @EnvironmentObject var manager: HydrationManager
    
    // Environment variable to dismiss the sheet
    // @Environment(\.dismiss) gives us a function to close this view
    // When we call dismiss(), the sheet will slide down and close
    
    @Environment(\.dismiss) var dismiss
    
    // State variable to store the current amount selected by the user
    // @State means this value is local to this view
    // When it changes, the view will re-render
    // Default value is 250ml
    
    @State private var amount = 250
    
    // MARK: - Body
    
    var body: some View {
        
        // VStack arranges all child views vertically (top to bottom)
        // spacing: 10 adds 10 points of space between each view
        
        VStack(spacing: 10) {
            
            // MARK: - Title
            
            // Display the title with a water drop emoji
            // .headline is a built-in font style for titles
            
            Text("💧 Custom Log")
                .font(.headline)
                .padding(.top, 4)  // Add small space at the top
            
            // MARK: - Amount Display
            
            // Display the current amount in a large, bold, rounded font
            // The text updates automatically when "amount" changes
            // Orange color makes it stand out and matches the theme
            
            Text("\(amount) ml")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundColor(.orange)
            
            // MARK: - Adjustment Controls
            
            // HStack arranges the controls horizontally (left to right)
            // spacing: 14 adds space between the minus button and presets
            
            HStack(spacing: 14) {
                
                // MARK: - Minus Button
                
                // Button that decreases the amount by 50ml
                // The action checks if amount > 50 before subtracting
                // This prevents the amount from going below 50ml
                // The red color indicates "decrease"
                
                Button(action: { if amount > 50 { amount -= 50 } }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)  // Removes default button styling
                
                // MARK: - Preset Buttons
                
                // HStack for the three preset amount buttons
                // ForEach loops through the array [250, 500, 750]
                // Each preset becomes a button with that value
                
                HStack(spacing: 4) {
                    ForEach([250, 500, 750], id: \.self) { preset in
                        
                        // Button for each preset value
                        // When tapped, it sets the amount to that value
                        
                        Button("\(preset)") {
                            amount = preset
                        }
                        .font(.caption2)  // Small font for the number
                        .fontWeight(.medium)
                        .frame(width: 30, height: 24)  // Fixed size for consistency
                        
                        // Background changes based on selection
                        // If this preset is selected → orange background
                        // Otherwise → light gray background
                        
                        .background(amount == preset ? Color.orange : Color.gray.opacity(0.12))
                        .cornerRadius(6)  // Rounded corners
                        
                        // Text color changes based on selection
                        // If selected → white text on orange background
                        // Otherwise → orange text on gray background
                        
                        .foregroundColor(amount == preset ? .white : .orange)
                        .buttonStyle(.plain)
                    }
                }
                
                // MARK: - Plus Button
                
                // Button that increases the amount by 50ml
                // The action checks if amount < 2000 before adding
                // This prevents the amount from exceeding 2000ml
                // The green color indicates "increase"
                
                Button(action: { if amount < 2000 { amount += 50 } }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.green)
                }
                .buttonStyle(.plain)
            }
            
            // MARK: - Confirm Button
            
            // The main action button - logs the water and closes the sheet
            // Purple color makes it stand out as the primary action
            
            Button(action: {
                manager.addWater(amount)  // Add water to today's intake
                dismiss()                // Close the sheet
            }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")  // Checkmark icon
                        .font(.system(size: 14))
                    Text("Confirm")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)  // White text for contrast
                .frame(maxWidth: .infinity)  // Stretch to fill available width
                .padding(.vertical, 10)  // Vertical padding for comfortable tapping
                .background(
                    RoundedRectangle(cornerRadius: 12)  // Rounded rectangle background
                        .fill(Color.purple)  // Purple fill color
                        .shadow(color: .purple.opacity(0.4), radius: 6)  // Subtle shadow for depth
                )
            }
            .buttonStyle(.plain)  // Removes default button styling
        }
        .padding()  // Add padding around the entire VStack
    }
}
