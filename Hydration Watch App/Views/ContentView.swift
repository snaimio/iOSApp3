//  =====================================
//  ContentView.swift
//  Hydration Watch App
//  Created by Sheikh Naim on 2026-06-18.
//  =====================================

// Import SwiftUI framework for building the user interface
// SwiftUI provides all the UI components like TabView, Label, etc.

import SwiftUI

// MARK: - ContentView
// This is the main container view for the entire app
// It manages the tab-based navigation between all the different screens
// The user can swipe left/right to switch between tabs

struct ContentView: View {
    
    // MARK: - Properties
    
    // Access to the HydrationManager (shared data and logic)
    // @EnvironmentObject allows this view to use the same manager instance
    // that was created in the parent view (HydrationApp)
    
    @EnvironmentObject var manager: HydrationManager
    
    // State variable to track which tab is currently selected
    // @State means this value is local to this view
    // When it changes, the view will re-render to show the selected tab
    // Default is 0 (first tab - Home)
    
    @State private var selectedTab = 0
    
    // MARK: - Body
    
    var body: some View {
        
        // TabView creates a page-based navigation interface
        // Users can swipe left/right to switch between tabs
        // selection: $selectedTab binds to the selectedTab state
        // This allows us to control which tab is shown
        
        TabView(selection: $selectedTab) {
            
            // MARK: - Tab 0: Home (First Tab)
            // The main dashboard with progress ring and quick add buttons
            
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")  // House icon for home
                }
                .tag(0)  // Tag identifies this tab (matches selectedTab value)
            
            // MARK: - Tab 2: Recent (Third Tab)
            // Shows today's logged entries with delete capability
            
            RecentLogsView()
                .tabItem {
                    Label("Recent", systemImage: "clock.fill")  // Clock icon for recent logs
                }
                .tag(2)  // Tag matches the order in the tab view
            
            // MARK: - Tab 1: Stats (Second Tab)
            // Shows statistics, charts, and overall progress
            
            StatisticsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")  // Bar chart icon for stats
                }
                .tag(1)  // Tag matches the order in the tab view
            
            // MARK: - Tab 3: Settings (Fourth Tab)
            // Allows user to customize goal, weight, reminders, etc.
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")  // Gear icon for settings
                }
                .tag(3)  // Tag matches the order in the tab view
        }
        .tabViewStyle(.page)  // Page style allows swipe gestures between tabs
        
        // MARK: - On Appear
        
        // .onAppear runs when the view first appears on screen
        // This is where we request notification permissions from the user
        
        .onAppear {
            requestNotificationPermission()  // Ask for permission when app opens
        }
    }
    
    // MARK: - Helper Functions
    
    // Requests permission from the user to send notifications
    // This is required before the app can show alerts and reminders
    
    private func requestNotificationPermission() {
        
        // Get the notification center (system service for notifications)
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound]  // We need alert and sound permissions
        ) { granted, _ in  // Closure runs when user responds
            
            // If the user granted permission...
            
            if granted {
                
                // Switch to the main thread for UI updates
                // @MainActor ensures this runs on the main thread
                
                Task { @MainActor in
                    manager.scheduleReminders()  // Schedule the reminders
                }
            }
        }
    }
}
