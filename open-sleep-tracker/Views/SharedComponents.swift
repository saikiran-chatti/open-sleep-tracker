//
//  SharedComponents.swift
//  open-sleep-tracker
//
//  Created by AI Agent on 11/22/25.
//

import SwiftUI

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.white)

            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}

// MARK: - Metric Components

struct MetricTile: View {
    let title: String
    let value: String
    let caption: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.7))
                .labelStyle(.iconOnly)
                .overlay(
                    Text(title)
                        .font(.footnote)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.7))
                        .offset(x: 24),
                    alignment: .leading
                )

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(caption)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.55))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .glassCard(
            cornerRadius: 22,
            tint: LinearGradient(
                colors: [.white.opacity(0.08), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            shadowColor: .black.opacity(0.25)
        )
    }
}

struct MetricPill: View {
    let title: String
    let value: String
    let icon: String
    var tint: Color = .accentBlue

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.7))
                .labelStyle(.iconLeading)

            Text(value)
                .font(.headline)
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(tint.opacity(0.16))
        )
        .overlay(
            Capsule()
                .stroke(tint.opacity(0.35), lineWidth: 1)
        )
    }
}

// MARK: - Badge & Status Components

struct BadgeView: View {
    let text: String
    let icon: String
    let color: Color

    var body: some View {
        Label {
            Text(text)
                .font(.caption2)
                .fontWeight(.semibold)
        } icon: {
            Image(systemName: icon)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.2))
        .clipShape(Capsule())
        .foregroundStyle(color)
    }
}

struct TrendBadge: View {
    let trend: DashboardData.Trend

    var body: some View {
        switch trend {
        case .up(let value):
            BadgeView(text: "+\(value)%", icon: "arrow.up.right", color: .accentGreen)
        case .down(let value):
            BadgeView(text: "-\(value)%", icon: "arrow.down.right", color: .accentOrange)
        case .steady:
            BadgeView(text: "Stable", icon: "equal", color: .accentTeal)
        }
    }
}

struct StatusPill: View {
    let state: DashboardData.Agent.State

    var body: some View {
        Label(state.label, systemImage: state.icon)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(state.color.opacity(0.2))
            .foregroundStyle(state.color)
            .clipShape(Capsule())
    }
}

// MARK: - Circular Score View

struct CircularScoreView: View {
    let score: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.08), lineWidth: 12)

            Circle()
                .trim(from: 0, to: CGFloat(score) / 100.0)
                .stroke(
                    AngularGradient(
                        colors: [.accentBlue, .accentPurple, .accentTeal],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 4) {
                Text("\(score)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Sleep Score")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .frame(width: 120, height: 120)
    }
}

// MARK: - App Background

struct AppBackgroundView: View {
    @State private var animate = false

    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.12, green: 0.14, blue: 0.24),
                Color(red: 0.09, green: 0.11, blue: 0.23),
                Color(red: 0.06, green: 0.08, blue: 0.18)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            RadialGradient(
                colors: [
                    Color.accentBlue.opacity(0.28),
                    Color.accentPurple.opacity(0.18),
                    .clear
                ],
                center: animate ? .bottomTrailing : .topLeading,
                startRadius: 60,
                endRadius: 520
            )
            .animation(
                .easeInOut(duration: 12)
                    .repeatForever(autoreverses: true),
                value: animate
            )
        )
        .overlay(
            AngularGradient(
                colors: [
                    .white.opacity(0.04),
                    .clear,
                    .accentPurple.opacity(0.06)
                ],
                center: animate ? .center : .topLeading,
                angle: .degrees(animate ? 90 : -120)
            )
            .blur(radius: 160)
        )
        .ignoresSafeArea()
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Glass Card Modifier

extension View {
    func glassCard(
        cornerRadius: CGFloat = 24,
        tint: LinearGradient? = nil,
        strokeColor: Color = .white.opacity(0.15),
        shadowColor: Color = .black.opacity(0.35)
    ) -> some View {
        modifier(
            GlassModifier(
                cornerRadius: cornerRadius,
                tint: tint,
                strokeColor: strokeColor,
                shadowColor: shadowColor
            )
        )
    }
}

struct GlassModifier: ViewModifier {
    let cornerRadius: CGFloat
    let tint: LinearGradient?
    let strokeColor: Color
    let shadowColor: Color

    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    if let tint {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(tint)
                    }

                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(strokeColor, lineWidth: 1)
                        )
                }
                .shadow(color: shadowColor, radius: 28, x: 0, y: 12)
            )
    }
}

// MARK: - Label Styles

extension LabelStyle where Self == IconLeadingLabelStyle {
    static var iconLeading: IconLeadingLabelStyle { IconLeadingLabelStyle() }
}

struct IconLeadingLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 10) {
            configuration.icon
            configuration.title
        }
    }
}

// MARK: - Color Extensions

extension Color {
    static let accentBlue = Color(red: 0.38, green: 0.55, blue: 0.97)
    static let accentPurple = Color(red: 0.67, green: 0.44, blue: 0.98)
    static let accentGreen = Color(red: 0.3, green: 0.84, blue: 0.6)
    static let accentOrange = Color(red: 0.98, green: 0.54, blue: 0.2)
    static let accentTeal = Color(red: 0.32, green: 0.82, blue: 0.86)
}

extension ShapeStyle where Self == Color {
    static var accentBlue: Color { Color.accentBlue }
    static var accentPurple: Color { Color.accentPurple }
    static var accentGreen: Color { Color.accentGreen }
    static var accentOrange: Color { Color.accentOrange }
    static var accentTeal: Color { Color.accentTeal }
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
