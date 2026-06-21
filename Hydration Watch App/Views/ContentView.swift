//
//  ContentView.swift
//  Hydration Watch App
//
//  Created by Sheikh Naim on 2026-06-18.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var manager: HydrationManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            RecentLogsView()
                         .tabItem {
                             Label("Recent", systemImage: "clock.fill")
                         }
                         .tag(2)
            
            StatisticsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .tabViewStyle(.page)
        .onAppear {
            requestNotificationPermission()
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
            if granted {
                Task { @MainActor in
                    manager.scheduleReminders()
                }
            }
        }
    }
}
