//
//  SharedComponents.swift
//  open-sleep-tracker
//
//  Apple-style minimalist design system
//

import SwiftUI
import Combine

// MARK: - Color System (Apple-style)

extension Color {
    // Primary accent - iOS blue
    static let appAccent = Color.blue

    // Semantic colors
    static let appGreen = Color.green
    static let appOrange = Color.orange
    static let appRed = Color.red
    static let appPurple = Color.purple
    static let appTeal = Color.teal
    static let appIndigo = Color.indigo

    // Background colors
    static let appBackground = Color(uiColor: .systemBackground)
    static let appSecondaryBackground = Color(uiColor: .secondarySystemBackground)
    static let appTertiaryBackground = Color(uiColor: .tertiarySystemBackground)
    static let appGroupedBackground = Color(uiColor: .systemGroupedBackground)

    // Text colors
    static let appPrimaryText = Color(uiColor: .label)
    static let appSecondaryText = Color(uiColor: .secondaryLabel)
    static let appTertiaryText = Color(uiColor: .tertiaryLabel)

    // Separator
    static let appSeparator = Color(uiColor: .separator)

    // Legacy support for existing code
    static let accentBlue = Color.blue
    static let accentPurple = Color.purple
    static let accentGreen = Color.green
    static let accentOrange = Color.orange
    static let accentTeal = Color.teal
}

extension ShapeStyle where Self == Color {
    static var accentBlue: Color { Color.blue }
    static var accentPurple: Color { Color.purple }
    static var accentGreen: Color { Color.green }
    static var accentOrange: Color { Color.orange }
    static var accentTeal: Color { Color.teal }
}

// MARK: - Theme System (Simplified)

enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case dark = "Dark"
    case light = "Light"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .dark: return .dark
        case .light: return .light
        }
    }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .dark: return "moon.fill"
        case .light: return "sun.max.fill"
        }
    }

    // Legacy support
    var accentColor: Color { .appAccent }
    var secondaryAccent: Color { .appPurple }
    var cardBackground: Color { .appSecondaryBackground }
    var textPrimary: Color { .appPrimaryText }
    var textSecondary: Color { .appSecondaryText }
    var textTertiary: Color { .appTertiaryText }
    var isGradient: Bool { false }
    var colors: [Color] { [.appBackground] }

    static var solidThemes: [AppTheme] { allCases }
    static var gradientThemes: [AppTheme] { [] }
}

class ThemeManager: ObservableObject {
    @Published var selectedTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selectedTheme")
        }
    }

    init() {
        let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme") ?? AppTheme.system.rawValue
        self.selectedTheme = AppTheme(rawValue: savedTheme) ?? .system
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Metric Tile (Apple Health Style)

struct MetricTile: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let title: String
    let value: String
    let caption: String
    let icon: String
    var tint: Color = .appAccent

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(tint)

                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(value)
                .font(.system(size: 28, weight: .semibold, design: .rounded))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())

            Text(caption)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.appSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Metric Pill (Compact)

struct MetricPill: View {
    let title: String
    let value: String
    let icon: String
    var tint: Color = .appAccent

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(title)
                    .font(.caption2)
            }
            .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(tint.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

// MARK: - Badge View

struct BadgeView: View {
    let text: String
    let icon: String
    let color: Color

    var body: some View {
        Label(text, systemImage: icon)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}

// MARK: - Trend Badge

struct TrendBadge: View {
    let trend: DashboardData.Trend

    var body: some View {
        switch trend {
        case .up(let value):
            BadgeView(text: "+\(value)%", icon: "arrow.up.right", color: .appGreen)
        case .down(let value):
            BadgeView(text: "-\(value)%", icon: "arrow.down.right", color: .appOrange)
        case .steady:
            BadgeView(text: "Stable", icon: "equal", color: .appTeal)
        }
    }
}

// MARK: - Status Pill

struct StatusPill: View {
    let state: DashboardData.Agent.State

    var body: some View {
        Label(state.label, systemImage: state.icon)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(state.color.opacity(0.15))
            .foregroundStyle(state.color)
            .clipShape(Capsule())
    }
}

// MARK: - Circular Score View (Apple Watch Style)

struct CircularScoreView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let score: Int
    @State private var animatedScore: CGFloat = 0

    private var circleSize: CGFloat {
        DeviceInfo.isIPad ? 130 : 110
    }

    private var lineWidth: CGFloat {
        DeviceInfo.isIPad ? 12 : 10
    }

    private var scoreColor: Color {
        if score >= 80 { return .appGreen }
        else if score >= 60 { return .appOrange }
        else { return .appRed }
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.appSeparator.opacity(0.3), lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: animatedScore / 100.0)
                .stroke(
                    scoreColor,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 0.8, dampingFraction: 0.8), value: animatedScore)

            VStack(spacing: 2) {
                Text("\(score)")
                    .font(.system(size: DeviceInfo.isIPad ? 38 : 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                Text("Score")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: circleSize, height: circleSize)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.2)) {
                animatedScore = CGFloat(score)
            }
        }
        .onChange(of: score) { newValue in
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                animatedScore = CGFloat(newValue)
            }
        }
    }
}

// MARK: - App Background (Clean)

struct AppBackgroundView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Color.appBackground
            .ignoresSafeArea()
    }
}

// MARK: - Card Modifier (Apple Style)

extension View {
    func cardStyle(padding: CGFloat = 16) -> some View {
        self
            .padding(padding)
            .background(Color.appSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    func groupedCardStyle() -> some View {
        self
            .background(Color.appSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    // Legacy support
    func themedCard(
        theme: AppTheme,
        cornerRadius: CGFloat = 12,
        padding: CGFloat = 16
    ) -> some View {
        self.cardStyle(padding: padding)
    }

    func glassCard(
        cornerRadius: CGFloat = 12,
        tint: LinearGradient? = nil,
        strokeColor: Color = .clear,
        shadowColor: Color = .clear
    ) -> some View {
        self
            .background(Color.appSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

// MARK: - Label Style

extension LabelStyle where Self == IconLeadingLabelStyle {
    static var iconLeading: IconLeadingLabelStyle { IconLeadingLabelStyle() }
}

struct IconLeadingLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            configuration.icon
            configuration.title
        }
    }
}

// MARK: - TimeInterval Extension

extension TimeInterval {
    var formattedDurationDescription: String {
        let totalMinutes = Int(self) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return "\(hours)h \(minutes)m"
    }
}

// MARK: - Glass Modifier (Legacy Support)

struct GlassModifier: ViewModifier {
    let cornerRadius: CGFloat
    let tint: LinearGradient?
    let strokeColor: Color
    let shadowColor: Color

    func body(content: Content) -> some View {
        content
            .background(Color.appSecondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
