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

    /// Current widget layout
    @Published var widgetLayout: WidgetLayout {
        didSet { UserDefaults.standard.set(widgetLayout.rawValue, forKey: "standby_widgetLayout") }
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

    // MARK: - Initialization

    init() {
        self.autoActivate = UserDefaults.standard.object(forKey: "standby_autoActivate") as? Bool ?? true
        self.redTintEnabled = UserDefaults.standard.object(forKey: "standby_redTint") as? Bool ?? false
        self.autoDimEnabled = UserDefaults.standard.object(forKey: "standby_autoDim") as? Bool ?? true
        self.brightness = UserDefaults.standard.object(forKey: "standby_brightness") as? Double ?? 0.3
        self.showSeconds = UserDefaults.standard.object(forKey: "standby_showSeconds") as? Bool ?? false
        self.keepScreenOn = UserDefaults.standard.object(forKey: "standby_keepScreenOn") as? Bool ?? true

        if let layoutRaw = UserDefaults.standard.string(forKey: "standby_widgetLayout"),
           let layout = WidgetLayout(rawValue: layoutRaw) {
            self.widgetLayout = layout
        } else {
            self.widgetLayout = .balanced
        }

        if let styleRaw = UserDefaults.standard.string(forKey: "standby_backgroundStyle"),
           let style = BackgroundStyle(rawValue: styleRaw) {
            self.backgroundStyle = style
        } else {
            self.backgroundStyle = .gradient
        }
    }

    // MARK: - Widget Layouts

    enum WidgetLayout: String, CaseIterable, Identifiable {
        case minimal = "Minimal"
        case clockFocused = "Clock Focused"
        case balanced = "Balanced"
        case recordingFocused = "Recording Focused"

        var id: String { rawValue }

        var description: String {
            switch self {
            case .minimal:
                return "Large clock with subtle recording indicator"
            case .clockFocused:
                return "Prominent time display with compact stats"
            case .balanced:
                return "Clock, recording status, and sleep metrics"
            case .recordingFocused:
                return "Real-time audio visualization and session details"
            }
        }

        var icon: String {
            switch self {
            case .minimal:
                return "clock"
            case .clockFocused:
                return "clock.badge"
            case .balanced:
                return "rectangle.split.2x1"
            case .recordingFocused:
                return "waveform.circle"
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
    @Published var currentLayoutIndex: Int = 0

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
