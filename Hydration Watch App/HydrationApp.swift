//
//  HydrationApp.swift
//  Hydration Watch App
//
//  Created by Sheikh Naim on 2026-06-18.
//

import SwiftUI

@main
struct HydrationApp: App {
    @StateObject private var manager = HydrationManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(manager)
        }
    }
}
