//
//  StandBySettings.swift
//  open-sleep-tracker
//
//  StandBy Mode configuration and settings
//

import SwiftUI
import Combine

/// StandBy Mode configuration manager
class StandBySettings: ObservableObject {

    // MARK: - Published Properties

    /// Auto-activate StandBy when recording starts (iPad only)
    @Published var autoActivate: Bool {
        didSet { UserDefaults.standard.set(autoActivate, forKey: "standby_autoActivate") }
    }

    /// Background style
    @Published var backgroundStyle: BackgroundStyle {
        didSet { UserDefaults.standard.set(backgroundStyle.rawValue, forKey: "standby_backgroundStyle") }
    }

    /// Red tint for nighttime viewing
    @Published var redTintEnabled: Bool {
        didSet { UserDefaults.standard.set(redTintEnabled, forKey: "standby_redTint") }
    }

    /// Auto-dim after inactivity
    @Published var autoDimEnabled: Bool {
        didSet { UserDefaults.standard.set(autoDimEnabled, forKey: "standby_autoDim") }
    }

    /// Brightness level (0.1 - 1.0)
    @Published var brightness: Double {
        didSet { UserDefaults.standard.set(brightness, forKey: "standby_brightness") }
    }

    /// Show seconds on clock
    @Published var showSeconds: Bool {
        didSet { UserDefaults.standard.set(showSeconds, forKey: "standby_showSeconds") }
    }

    /// Keep screen on during StandBy
    @Published var keepScreenOn: Bool {
        didSet { UserDefaults.standard.set(keepScreenOn, forKey: "standby_keepScreenOn") }
    }

    /// Enabled widget pages
    @Published var enabledPages: [StandByPage] {
        didSet {
            let pageIds = enabledPages.map { $0.rawValue }
            UserDefaults.standard.set(pageIds, forKey: "standby_enabledPages")
        }
    }

    /// Widgets enabled for the widgets page
    @Published var enabledWidgets: [WidgetType] {
        didSet {
            let widgetIds = enabledWidgets.map { $0.rawValue }
            UserDefaults.standard.set(widgetIds, forKey: "standby_enabledWidgets")
        }
    }

    // MARK: - Initialization

    init() {
        self.autoActivate = UserDefaults.standard.object(forKey: "standby_autoActivate") as? Bool ?? true
        self.redTintEnabled = UserDefaults.standard.object(forKey: "standby_redTint") as? Bool ?? false
        self.autoDimEnabled = UserDefaults.standard.object(forKey: "standby_autoDim") as? Bool ?? true
        self.brightness = UserDefaults.standard.object(forKey: "standby_brightness") as? Double ?? 0.3
        self.showSeconds = UserDefaults.standard.object(forKey: "standby_showSeconds") as? Bool ?? false
        self.keepScreenOn = UserDefaults.standard.object(forKey: "standby_keepScreenOn") as? Bool ?? true

        if let styleRaw = UserDefaults.standard.string(forKey: "standby_backgroundStyle"),
           let style = BackgroundStyle(rawValue: styleRaw) {
            self.backgroundStyle = style
        } else {
            self.backgroundStyle = .gradient
        }

        // Load enabled pages
        if let pageIds = UserDefaults.standard.array(forKey: "standby_enabledPages") as? [String] {
            self.enabledPages = pageIds.compactMap { StandByPage(rawValue: $0) }
        } else {
            self.enabledPages = [.clock, .widgets, .recording]
        }

        // Load enabled widgets
        if let widgetIds = UserDefaults.standard.array(forKey: "standby_enabledWidgets") as? [String] {
            self.enabledWidgets = widgetIds.compactMap { WidgetType(rawValue: $0) }
        } else {
            self.enabledWidgets = [.sleepScore, .previousNight, .environment, .recordings]
        }
    }

    // MARK: - StandBy Pages

    enum StandByPage: String, CaseIterable, Identifiable {
        case clock = "Clock"
        case widgets = "Widgets"
        case recording = "Recording"
        case metrics = "Metrics"

        var id: String { rawValue }

        var description: String {
            switch self {
            case .clock:
                return "Large clock display with date"
            case .widgets:
                return "Customizable sleep tracking widgets"
            case .recording:
                return "Live audio visualization and status"
            case .metrics:
                return "Detailed session metrics"
            }
        }

        var icon: String {
            switch self {
            case .clock:
                return "clock"
            case .widgets:
                return "square.grid.2x2"
            case .recording:
                return "waveform.circle"
            case .metrics:
                return "chart.bar"
            }
        }
    }

    // MARK: - Widget Types

    enum WidgetType: String, CaseIterable, Identifiable {
        case sleepScore = "Sleep Score"
        case previousNight = "Previous Night"
        case environment = "Environment"
        case recordings = "Recordings"
        case sleepGoals = "Sleep Goals"
        case sleepStreak = "Sleep Streak"
        case weeklyTrend = "Weekly Trend"
        case activeAgents = "Active Agents"
        case heartRate = "Heart Rate"
        case bedtimeCountdown = "Bedtime Countdown"

        var id: String { rawValue }

        var description: String {
            switch self {
            case .sleepScore:
                return "Tonight's or average sleep score"
            case .previousNight:
                return "Last night's sleep summary"
            case .environment:
                return "Room temperature, humidity, noise"
            case .recordings:
                return "Total sessions and snore events"
            case .sleepGoals:
                return "Progress toward sleep goals"
            case .sleepStreak:
                return "Consecutive nights of good sleep"
            case .weeklyTrend:
                return "Sleep quality over the week"
            case .activeAgents:
                return "AI agents running status"
            case .heartRate:
                return "Current heart rate (if available)"
            case .bedtimeCountdown:
                return "Time until target bedtime"
            }
        }

        var icon: String {
            switch self {
            case .sleepScore:
                return "gauge.with.needle"
            case .previousNight:
                return "moon.zzz"
            case .environment:
                return "thermometer.medium"
            case .recordings:
                return "waveform"
            case .sleepGoals:
                return "target"
            case .sleepStreak:
                return "flame"
            case .weeklyTrend:
                return "chart.line.uptrend.xyaxis"
            case .activeAgents:
                return "cpu.fill"
            case .heartRate:
                return "heart.fill"
            case .bedtimeCountdown:
                return "clock.badge.checkmark"
            }
        }
    }

    // MARK: - Background Styles

    enum BackgroundStyle: String, CaseIterable, Identifiable {
        case solid = "Solid"
        case gradient = "Gradient"
        case aurora = "Aurora"
        case stars = "Stars"
        case minimal = "Pure Black"

        var id: String { rawValue }

        var description: String {
            switch self {
            case .solid:
                return "Subtle dark background"
            case .gradient:
                return "Smooth gradient transitions"
            case .aurora:
                return "Northern lights inspired"
            case .stars:
                return "Starfield ambience"
            case .minimal:
                return "Pure black for OLED"
            }
        }

        var icon: String {
            switch self {
            case .solid:
                return "square.fill"
            case .gradient:
                return "square.lefthalf.filled"
            case .aurora:
                return "sparkles"
            case .stars:
                return "star.fill"
            case .minimal:
                return "moon.fill"
            }
        }
    }
}

// MARK: - StandBy State

/// Manages the current state of StandBy mode
class StandByState: ObservableObject {
    @Published var isActive: Bool = false
    @Published var isDimmed: Bool = false
    @Published var lastInteraction: Date = Date()
    @Published var currentPageIndex: Int = 0

    func activate() {
        isActive = true
        lastInteraction = Date()
    }

    func deactivate() {
        isActive = false
        isDimmed = false
    }

    func recordInteraction() {
        lastInteraction = Date()
        isDimmed = false
    }
}
