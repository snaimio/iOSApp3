# 💧 Hydration Tracker - watchOS App

A complete hydration tracking app for Apple Watch that helps users stay hydrated throughout the day.

## 📱 Features

- **Log Water** - Quick add buttons (+250ml, +500ml, +1000ml) and custom amount picker
- **Progress Ring** - Visual circular progress showing daily intake
- **Daily Goal** - Set custom hydration goal (manual or weight-based)
- **Streak Tracking** - Consecutive days meeting hydration goal
- **Statistics** - View total days, average intake, best day, and weekly progress chart
- **Recent Logs** - View and delete today's entries
- **Reminders** - Customizable notification intervals (1-4 hours)
- **Overhydration Warning** - Alerts when exceeding safe daily limits
- **Haptic Feedback** - Physical feedback on all actions
- **Data Persistence** - All data saved locally using UserDefaults

## 🛠️ Technologies Used

- SwiftUI
- ObservableObject / @Published
- UserDefaults
- UNUserNotificationCenter
- WatchKit (Haptic Feedback)
- Combine

## 📁 Project Structure

```
Hydration Watch App/
├── HydrationApp.swift          (App entry point)
├── Models/
│   ├── HydrationManager.swift  (Business logic)
│   └── Models.swift            (Data models)
├── Views/
│   ├── ContentView.swift       (Tab navigation)
│   ├── HomeView.swift          (Main dashboard)
│   ├── StatisticsView.swift    (Statistics & charts)
│   ├── RecentLogsView.swift    (Today's entries)
│   ├── SettingsView.swift      (App settings)
│   └── AddWaterView.swift      (Custom log sheet)
└── Assets.xcassets             (App icon)
```

## 🚀 How to Run

1. Clone the repository
2. Open `Hydration.xcodeproj` in Xcode
3. Select Apple Watch target
4. Build and run (⌘R)

## 👨‍💻 Author

Sheikh Naim

## 📄 License

MIT License - see LICENSE file for details
