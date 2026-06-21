//  =====================================
//  HydrationApp.swift
//  Hydration Watch App
//  Created by Sheikh Naim on 2026-06-18.
//  =====================================

// Import SwiftUI framework for building the user interface
// SwiftUI provides all the necessary components for building the app

import SwiftUI

// MARK: - HydrationApp
// This is the main entry point of the application
// The @main attribute tells Swift that this is the starting point of the app
// The app follows the App protocol which defines the app's structure and behavior

@main
struct HydrationApp: App {
    
    // MARK: - Properties
    
    // @StateObject creates and owns the HydrationManager instance
    // It stays alive for the entire lifetime of the app
    // private means only this struct can access it directly
    // This manager handles all the app's data and business logic
    
    @StateObject private var manager = HydrationManager()
    
    // MARK: - Body
    
    // The body property defines the app's content and structure
    // WindowGroup is the container for the app's main window
    
    var body: some Scene {
        WindowGroup {
            
            // ContentView is the root view of the app
            // It contains all the tabs and navigation
            
            ContentView()
            
            // .environmentObject injects the manager into the environment
            // This makes the manager available to all child views
            // Any view can access it using @EnvironmentObject
            
                .environmentObject(manager)
        }
    }
}
