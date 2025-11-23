//
//  SettingsView.swift
//  open-sleep-tracker
//
//  Created by AI Agent on 11/22/25.
//

import SwiftUI

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var notificationsEnabled = true
    @State private var healthSyncEnabled = true
    @State private var standbyWidgetsEnabled = true
    @State private var advancedMode = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                List {
                    Section("Appearance") {
                        NavigationLink {
                            ThemeSelectionView()
                        } label: {
                            HStack {
                                Label("Theme", systemImage: "paintpalette.fill")
                                Spacer()
                                HStack(spacing: 6) {
                                    Image(systemName: themeManager.selectedTheme.icon)
                                        .foregroundStyle(themeManager.selectedTheme.accentColor)
                                    Text(themeManager.selectedTheme.rawValue)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }

                    Section("Agents") {
                        Toggle(isOn: $advancedMode) {
                            Label("Advanced Agent Strategies", systemImage: "brain.head.profile")
                        }

                        NavigationLink {
                            AgentDetailSettingsView()
                        } label: {
                            Label("Agent Configurations", systemImage: "slider.horizontal.2.square.on.square")
                        }
                    }

                    Section("Notifications") {
                        Toggle(isOn: $notificationsEnabled) {
                            Label("Adaptive Notifications", systemImage: "bell.badge.waveform")
                        }

                        Toggle(isOn: $standbyWidgetsEnabled) {
                            Label("StandBy Widgets", systemImage: "display")
                        }
                    }

                    Section("Health & Privacy") {
                        Toggle(isOn: $healthSyncEnabled) {
                            Label("HealthKit Synchronization", systemImage: "heart.text.square")
                        }

                        NavigationLink {
                            PrivacyCenterView()
                        } label: {
                            Label("Privacy Center", systemImage: "lock.shield")
                        }
                    }

                    Section("Data Management") {
                        NavigationLink {
                            DataManagementView()
                        } label: {
                            Label("Storage & Export", systemImage: "externaldrive")
                        }

                        NavigationLink {
                            CloudSyncView()
                        } label: {
                            Label("Cloud Sync", systemImage: "icloud")
                        }
                    }

                    Section("Support") {
                        NavigationLink {
                            HelpView()
                        } label: {
                            Label("Help & Documentation", systemImage: "questionmark.circle")
                        }

                        NavigationLink {
                            FeedbackView()
                        } label: {
                            Label("Feedback", systemImage: "bubble.left.and.bubble.right")
                        }

                        NavigationLink {
                            AboutView()
                        } label: {
                            Label("About", systemImage: "info.circle")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Agent Detail Settings

struct AgentDetailSettingsView: View {
    @State private var audioSensitivity: Double = 0.65
    @State private var snoreThreshold: Double = 0.45
    @State private var patternLookback: Int = 14
    @State private var autoModelUpdates = true
    @State private var backgroundProcessing = true
    @State private var intelligentNotifications = true

    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Sensitivity")
                        Spacer()
                        Text("\(Int(audioSensitivity * 100))%")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $audioSensitivity, in: 0.2...1.0)
                        .tint(.accentBlue)
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Snore Threshold")
                        Spacer()
                        Text("\(Int(snoreThreshold * 100))%")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $snoreThreshold, in: 0.1...0.9)
                        .tint(.accentOrange)
                }

                Toggle("Auto-update Models", isOn: $autoModelUpdates)
            } header: {
                Label("Audio Classification Agent", systemImage: "waveform.circle.fill")
            } footer: {
                Text("Higher sensitivity detects more subtle sounds. Adjust threshold to filter false positives.")
            }

            Section {
                Stepper(value: $patternLookback, in: 7...60, step: 7) {
                    HStack {
                        Text("Historical Lookback")
                        Spacer()
                        Text("\(patternLookback) days")
                            .foregroundStyle(.secondary)
                    }
                }

                Toggle("Background Processing", isOn: $backgroundProcessing)
            } header: {
                Label("Sleep Pattern Analysis Agent", systemImage: "chart.xyaxis.line")
            } footer: {
                Text("Longer lookback periods provide more accurate trend analysis but use more storage.")
            }

            Section {
                Toggle("Smart Timing", isOn: $intelligentNotifications)

                NavigationLink("Notification Schedule") {
                    NotificationScheduleView()
                }
            } header: {
                Label("Intelligent Notification Agent", systemImage: "bell.badge.waveform.fill")
            } footer: {
                Text("Smart timing learns your preferences and sends notifications at optimal times.")
            }

            Section {
                NavigationLink("Health Data Sources") {
                    HealthSourcesView()
                }

                NavigationLink("Sync Preferences") {
                    SyncPreferencesView()
                }
            } header: {
                Label("Health Integration Agent", systemImage: "heart.text.square")
            }

            Section {
                NavigationLink("StandBy Appearance") {
                    StandByAppearanceView()
                }

                NavigationLink("Widget Configuration") {
                    WidgetConfigView()
                }
            } header: {
                Label("StandBy Intelligence Agent", systemImage: "display")
            }
        }
        .navigationTitle("Agent Configurations")
    }
}

// MARK: - Privacy Center

struct PrivacyCenterView: View {
    var body: some View {
        Form {
            Section("Data Transparency") {
                HStack {
                    Label("On-device Processing", systemImage: "cpu")
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.accentGreen)
                }

                HStack {
                    Label("Secure Enclave Enabled", systemImage: "lock.shield")
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.accentGreen)
                }

                HStack {
                    Label("Encrypted Cloud Sync", systemImage: "icloud.and.arrow.up")
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.accentGreen)
                }
            }

            Section("Permissions") {
                HStack {
                    Label("Health Data", systemImage: "heart.fill")
                    Spacer()
                    Text("Authorized")
                        .foregroundStyle(.accentGreen)
                }

                HStack {
                    Label("Microphone Access", systemImage: "mic.fill")
                    Spacer()
                    Text("Granted")
                        .foregroundStyle(.accentGreen)
                }

                HStack {
                    Label("Notifications", systemImage: "bell.badge")
                    Spacer()
                    Text("Scheduled")
                        .foregroundStyle(.accentBlue)
                }
            }

            Section("Data Controls") {
                Button("Export All Data") {
                    // Export action
                }

                Button("Delete All Data", role: .destructive) {
                    // Delete action
                }
            }
        }
        .navigationTitle("Privacy Center")
    }
}

// MARK: - Placeholder Views

struct DataManagementView: View {
    var body: some View {
        Form {
            Section("Storage") {
                HStack {
                    Text("Audio Recordings")
                    Spacer()
                    Text("245 MB")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Sleep Data")
                    Spacer()
                    Text("12 MB")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Analytics Cache")
                    Spacer()
                    Text("8 MB")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Export") {
                Button("Export to Health App") { }
                Button("Export as CSV") { }
                Button("Export as JSON") { }
            }
        }
        .navigationTitle("Storage & Export")
    }
}

struct CloudSyncView: View {
    @State private var iCloudEnabled = true
    @State private var lastSynced = "2 minutes ago"

    var body: some View {
        Form {
            Section {
                Toggle("iCloud Sync", isOn: $iCloudEnabled)

                HStack {
                    Text("Last Synced")
                    Spacer()
                    Text(lastSynced)
                        .foregroundStyle(.secondary)
                }

                Button("Sync Now") { }
            }

            Section("Sync Options") {
                Toggle("Audio Recordings", isOn: .constant(true))
                Toggle("Sleep Analytics", isOn: .constant(true))
                Toggle("Agent Configurations", isOn: .constant(true))
            }
        }
        .navigationTitle("Cloud Sync")
    }
}

struct HelpView: View {
    var body: some View {
        List {
            Section("Getting Started") {
                NavigationLink("How to Start a Sleep Session") { Text("Guide content") }
                NavigationLink("Understanding Your Sleep Score") { Text("Guide content") }
                NavigationLink("Configuring AI Agents") { Text("Guide content") }
            }

            Section("Features") {
                NavigationLink("Audio Classification") { Text("Feature info") }
                NavigationLink("Sleep Pattern Analysis") { Text("Feature info") }
                NavigationLink("Health Integration") { Text("Feature info") }
            }

            Section("Troubleshooting") {
                NavigationLink("Audio Not Recording") { Text("Troubleshooting") }
                NavigationLink("HealthKit Sync Issues") { Text("Troubleshooting") }
                NavigationLink("Notification Problems") { Text("Troubleshooting") }
            }
        }
        .navigationTitle("Help & Documentation")
    }
}

struct FeedbackView: View {
    @State private var feedbackText = ""
    @State private var feedbackType = "Bug Report"
    let feedbackTypes = ["Bug Report", "Feature Request", "General Feedback"]

    var body: some View {
        Form {
            Section {
                Picker("Type", selection: $feedbackType) {
                    ForEach(feedbackTypes, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }

                TextEditor(text: $feedbackText)
                    .frame(minHeight: 150)
            }

            Section {
                Button("Submit Feedback") { }
                    .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Feedback")
    }
}

struct AboutView: View {
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("Build")
                    Spacer()
                    Text("2025.11.22")
                        .foregroundStyle(.secondary)
                }
            }

            Section("AI Agents") {
                Text("This app uses 6 specialized AI agents to provide intelligent sleep tracking and analysis.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Section {
                Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
            }
        }
        .navigationTitle("About")
    }
}

// MARK: - Additional Placeholder Views

struct NotificationScheduleView: View {
    var body: some View {
        Form {
            Section("Bedtime Reminders") {
                Toggle("Wind-down Reminder", isOn: .constant(true))
                DatePicker("Time", selection: .constant(Date()), displayedComponents: .hourAndMinute)
            }

            Section("Morning Reports") {
                Toggle("Daily Sleep Report", isOn: .constant(true))
                DatePicker("Time", selection: .constant(Date()), displayedComponents: .hourAndMinute)
            }
        }
        .navigationTitle("Notification Schedule")
    }
}

struct HealthSourcesView: View {
    var body: some View {
        Form {
            Section {
                Toggle("Apple Watch", isOn: .constant(true))
                Toggle("iPhone Motion", isOn: .constant(true))
                Toggle("Heart Rate", isOn: .constant(true))
                Toggle("Respiratory Rate", isOn: .constant(true))
            }
        }
        .navigationTitle("Health Data Sources")
    }
}

struct SyncPreferencesView: View {
    var body: some View {
        Form {
            Section {
                Toggle("Background Sync", isOn: .constant(true))
                Toggle("WiFi Only", isOn: .constant(false))
            }
        }
        .navigationTitle("Sync Preferences")
    }
}

struct StandByAppearanceView: View {
    var body: some View {
        Form {
            Section {
                Toggle("Auto Brightness", isOn: .constant(true))
                Toggle("Night Mode", isOn: .constant(true))
            }
        }
        .navigationTitle("StandBy Appearance")
    }
}

struct WidgetConfigView: View {
    var body: some View {
        Form {
            Section {
                Toggle("Sleep Score", isOn: .constant(true))
                Toggle("Recording Status", isOn: .constant(true))
                Toggle("Next Alarm", isOn: .constant(true))
            }
        }
        .navigationTitle("Widget Configuration")
    }
}

// MARK: - Theme Selection View

struct ThemeSelectionView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ZStack {
            AppBackgroundView()

            List {
                Section("Solid Themes") {
                    ForEach(AppTheme.solidThemes) { theme in
                        ThemeRow(theme: theme, isSelected: themeManager.selectedTheme == theme) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                themeManager.selectedTheme = theme
                            }
                        }
                    }
                }

                Section("Gradient Themes") {
                    ForEach(AppTheme.gradientThemes) { theme in
                        ThemeRow(theme: theme, isSelected: themeManager.selectedTheme == theme) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                themeManager.selectedTheme = theme
                            }
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Theme")
    }
}

struct ThemeRow: View {
    let theme: AppTheme
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Theme preview
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        theme.colors.count == 1
                            ? AnyShapeStyle(theme.colors[0])
                            : AnyShapeStyle(LinearGradient(
                                colors: theme.colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                    )
                    .frame(width: 44, height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(theme.accentColor.opacity(0.5), lineWidth: 1)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: theme.icon)
                            .foregroundStyle(theme.accentColor)
                            .font(.footnote)
                        Text(theme.rawValue)
                            .foregroundStyle(.primary)
                    }

                    Text(theme.isGradient ? "Gradient" : "Solid")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.accentBlue)
                        .font(.title3)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
