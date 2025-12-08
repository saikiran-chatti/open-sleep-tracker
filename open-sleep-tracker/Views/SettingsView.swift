//
//  SettingsView.swift
//  open-sleep-tracker
//
//  Apple-style Settings
//

import SwiftUI

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var notificationsEnabled = true
    @State private var healthSyncEnabled = true
    @State private var standbyWidgetsEnabled = true
    @State private var advancedMode = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        AppearanceSettingsView()
                    } label: {
                        Label("Appearance", systemImage: "paintbrush")
                    }
                }

                Section("Sleep Tracking") {
                    Toggle(isOn: $advancedMode) {
                        Label("Advanced Analysis", systemImage: "brain.head.profile")
                    }

                    NavigationLink {
                        AgentSettingsView()
                    } label: {
                        Label("AI Agents", systemImage: "cpu")
                    }
                }

                Section("Notifications") {
                    Toggle(isOn: $notificationsEnabled) {
                        Label("Sleep Reminders", systemImage: "bell")
                    }

                    Toggle(isOn: $standbyWidgetsEnabled) {
                        Label("Widget Updates", systemImage: "square.grid.2x2")
                    }
                }

                if DeviceInfo.isIPad {
                    Section {
                        NavigationLink {
                            StandBySettingsView()
                        } label: {
                            Label("StandBy Mode", systemImage: "display")
                        }
                    } footer: {
                        Text("Use your iPad as a bedside display during sleep tracking")
                    }
                }

                Section("Health") {
                    Toggle(isOn: $healthSyncEnabled) {
                        Label("HealthKit Sync", systemImage: "heart")
                    }

                    NavigationLink {
                        PrivacySettingsView()
                    } label: {
                        Label("Privacy", systemImage: "hand.raised")
                    }
                }

                Section("Data") {
                    NavigationLink {
                        StorageSettingsView()
                    } label: {
                        Label("Storage", systemImage: "internaldrive")
                    }

                    NavigationLink {
                        CloudSettingsView()
                    } label: {
                        Label("iCloud Sync", systemImage: "icloud")
                    }
                }

                Section("Support") {
                    NavigationLink {
                        HelpView()
                    } label: {
                        Label("Help", systemImage: "questionmark.circle")
                    }

                    NavigationLink {
                        AboutView()
                    } label: {
                        Label("About", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}

// MARK: - Appearance Settings

struct AppearanceSettingsView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        List {
            Section {
                ForEach(AppTheme.allCases) { theme in
                    Button {
                        themeManager.selectedTheme = theme
                    } label: {
                        HStack {
                            Label(theme.rawValue, systemImage: theme.icon)
                                .foregroundStyle(.primary)

                            Spacer()

                            if themeManager.selectedTheme == theme {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
            } header: {
                Text("Theme")
            } footer: {
                Text("Choose how the app appears. System matches your device settings.")
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Agent Settings

struct AgentSettingsView: View {
    @State private var audioSensitivity: Double = 0.65
    @State private var snoreThreshold: Double = 0.45
    @State private var patternLookback: Int = 14
    @State private var autoModelUpdates = true
    @State private var backgroundProcessing = true

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Sensitivity")
                        Spacer()
                        Text("\(Int(audioSensitivity * 100))%")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $audioSensitivity, in: 0.2...1.0)
                }

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Snore Threshold")
                        Spacer()
                        Text("\(Int(snoreThreshold * 100))%")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $snoreThreshold, in: 0.1...0.9)
                }

                Toggle("Auto-update Models", isOn: $autoModelUpdates)
            } header: {
                Label("Audio Classification", systemImage: "waveform")
            } footer: {
                Text("Higher sensitivity detects more subtle sounds")
            }

            Section {
                Stepper(value: $patternLookback, in: 7...60, step: 7) {
                    HStack {
                        Text("History")
                        Spacer()
                        Text("\(patternLookback) days")
                            .foregroundStyle(.secondary)
                    }
                }

                Toggle("Background Processing", isOn: $backgroundProcessing)
            } header: {
                Label("Sleep Analysis", systemImage: "chart.xyaxis.line")
            }
        }
        .navigationTitle("AI Agents")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Privacy Settings

struct PrivacySettingsView: View {
    var body: some View {
        List {
            Section("Data Processing") {
                LabeledContent("On-device AI") {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }

                LabeledContent("Encryption") {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }

            Section("Permissions") {
                LabeledContent("Microphone") {
                    Text("Granted")
                        .foregroundStyle(.green)
                }

                LabeledContent("Health Data") {
                    Text("Authorized")
                        .foregroundStyle(.green)
                }

                LabeledContent("Notifications") {
                    Text("Enabled")
                        .foregroundStyle(.blue)
                }
            }

            Section {
                Button("Export My Data") { }

                Button("Delete All Data", role: .destructive) { }
            }
        }
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Storage Settings

struct StorageSettingsView: View {
    var body: some View {
        List {
            Section("Usage") {
                LabeledContent("Recordings", value: "245 MB")
                LabeledContent("Sleep Data", value: "12 MB")
                LabeledContent("Cache", value: "8 MB")
            }

            Section("Export") {
                Button("Export to Health") { }
                Button("Export as CSV") { }
                Button("Export as JSON") { }
            }

            Section {
                Button("Clear Cache") { }
                Button("Delete Old Recordings", role: .destructive) { }
            }
        }
        .navigationTitle("Storage")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Cloud Settings

struct CloudSettingsView: View {
    @State private var iCloudEnabled = true

    var body: some View {
        List {
            Section {
                Toggle("iCloud Sync", isOn: $iCloudEnabled)
                LabeledContent("Last Synced", value: "2 min ago")
                Button("Sync Now") { }
            }

            Section("Sync Options") {
                Toggle("Recordings", isOn: .constant(true))
                Toggle("Sleep Data", isOn: .constant(true))
                Toggle("Settings", isOn: .constant(true))
            }
        }
        .navigationTitle("iCloud")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Help View

struct HelpView: View {
    var body: some View {
        List {
            Section("Getting Started") {
                NavigationLink("Start a Sleep Session") {
                    HelpDetailView(title: "Sleep Sessions", content: "Tap the moon button to begin tracking your sleep.")
                }
                NavigationLink("Understanding Sleep Scores") {
                    HelpDetailView(title: "Sleep Scores", content: "Your score is based on duration, quality, and patterns.")
                }
            }

            Section("Troubleshooting") {
                NavigationLink("Audio Issues") {
                    HelpDetailView(title: "Audio", content: "Make sure microphone permissions are enabled.")
                }
                NavigationLink("Sync Problems") {
                    HelpDetailView(title: "Sync", content: "Check your internet connection and iCloud settings.")
                }
            }

            Section {
                Link("Contact Support", destination: URL(string: "mailto:support@example.com")!)
            }
        }
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HelpDetailView: View {
    let title: String
    let content: String

    var body: some View {
        ScrollView {
            Text(content)
                .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - About View

struct AboutView: View {
    var body: some View {
        List {
            Section {
                LabeledContent("Version", value: "1.0.0")
                LabeledContent("Build", value: "2025.12")
            }

            Section {
                Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                Link("Terms of Service", destination: URL(string: "https://example.com/terms")!)
            }

            Section {
                Text("Sleep Tracker uses on-device AI to analyze your sleep patterns and provide personalized insights.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - StandBy Settings

struct StandBySettingsView: View {
    @StateObject private var settings = StandBySettings()

    var body: some View {
        List {
            Section {
                Toggle("Auto-Activate", isOn: $settings.autoActivate)
                Toggle("Keep Screen On", isOn: $settings.keepScreenOn)
            } header: {
                Text("Behavior")
            } footer: {
                Text("Auto-activate enters StandBy when recording starts")
            }

            Section {
                Toggle("Night Mode (Red Tint)", isOn: $settings.redTintEnabled)
                Toggle("Auto-Dim", isOn: $settings.autoDimEnabled)

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Brightness")
                        Spacer()
                        Text("\(Int(settings.brightness * 100))%")
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $settings.brightness, in: 0.1...1.0)
                }
            } header: {
                Text("Display")
            }

            Section {
                NavigationLink("Pages") {
                    PageSettingsView(settings: settings)
                }
                NavigationLink("Widgets") {
                    WidgetSettingsView(settings: settings)
                }
            } header: {
                Text("Content")
            }
        }
        .navigationTitle("StandBy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PageSettingsView: View {
    @ObservedObject var settings: StandBySettings

    var body: some View {
        List {
            ForEach(StandBySettings.StandByPage.allCases) { page in
                Toggle(isOn: Binding(
                    get: { settings.enabledPages.contains(page) },
                    set: { enabled in
                        if enabled {
                            if !settings.enabledPages.contains(page) {
                                settings.enabledPages.append(page)
                            }
                        } else {
                            settings.enabledPages.removeAll { $0 == page }
                        }
                    }
                )) {
                    Label(page.rawValue, systemImage: page.icon)
                }
            }
        }
        .navigationTitle("Pages")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WidgetSettingsView: View {
    @ObservedObject var settings: StandBySettings

    var body: some View {
        List {
            ForEach(StandBySettings.WidgetType.allCases) { widget in
                Toggle(isOn: Binding(
                    get: { settings.enabledWidgets.contains(widget) },
                    set: { enabled in
                        if enabled {
                            if !settings.enabledWidgets.contains(widget) {
                                settings.enabledWidgets.append(widget)
                            }
                        } else {
                            settings.enabledWidgets.removeAll { $0 == widget }
                        }
                    }
                )) {
                    Label(widget.rawValue, systemImage: widget.icon)
                }
            }
        }
        .navigationTitle("Widgets")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Legacy Support

struct ThemeSelectionView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        AppearanceSettingsView()
    }
}

struct ThemeRow: View {
    let theme: AppTheme
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                Label(theme.rawValue, systemImage: theme.icon)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(.blue)
                }
            }
        }
    }
}

struct AgentDetailSettingsView: View {
    var body: some View {
        AgentSettingsView()
    }
}

struct PrivacyCenterView: View {
    var body: some View {
        PrivacySettingsView()
    }
}

struct DataManagementView: View {
    var body: some View {
        StorageSettingsView()
    }
}

struct CloudSyncView: View {
    var body: some View {
        CloudSettingsView()
    }
}

struct FeedbackView: View {
    @State private var feedbackText = ""

    var body: some View {
        Form {
            Section {
                TextEditor(text: $feedbackText)
                    .frame(minHeight: 150)
            }

            Section {
                Button("Submit") { }
                    .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Feedback")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NotificationScheduleView: View {
    var body: some View {
        List {
            Section("Bedtime") {
                Toggle("Wind-down Reminder", isOn: .constant(true))
            }

            Section("Morning") {
                Toggle("Daily Report", isOn: .constant(true))
            }
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct HealthSourcesView: View {
    var body: some View {
        List {
            Toggle("Apple Watch", isOn: .constant(true))
            Toggle("Heart Rate", isOn: .constant(true))
        }
        .navigationTitle("Health Sources")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SyncPreferencesView: View {
    var body: some View {
        List {
            Toggle("Background Sync", isOn: .constant(true))
            Toggle("WiFi Only", isOn: .constant(false))
        }
        .navigationTitle("Sync")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StandByAppearanceView: View {
    var body: some View {
        List {
            Toggle("Auto Brightness", isOn: .constant(true))
            Toggle("Night Mode", isOn: .constant(true))
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WidgetConfigView: View {
    var body: some View {
        List {
            Toggle("Sleep Score", isOn: .constant(true))
            Toggle("Recording Status", isOn: .constant(true))
        }
        .navigationTitle("Widgets")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PageCustomizationView: View {
    @ObservedObject var settings: StandBySettings

    var body: some View {
        PageSettingsView(settings: settings)
    }
}

struct WidgetCustomizationView: View {
    @ObservedObject var settings: StandBySettings

    var body: some View {
        WidgetSettingsView(settings: settings)
    }
}
