//
//  AnalyticsView.swift
//  open-sleep-tracker
//
//  Created by AI Agent on 11/22/25.
//

import SwiftUI

// MARK: - Analytics View

struct AnalyticsView: View {
    @State private var analytics = DashboardData.Analytics.sample
    @State private var selectedTimeRange: TimeRange = .week

    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case quarter = "Quarter"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 24) {
                        // Time Range Picker
                        Picker("Time Range", selection: $selectedTimeRange) {
                            ForEach(TimeRange.allCases, id: \.self) { range in
                                Text(range.rawValue).tag(range)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal, 4)

                        AnalyticsOverview(analytics: analytics)
                        SleepQualityChart(analytics: analytics)
                        TrendCards(trends: analytics.trends)
                        FocusAreas(focusAreas: analytics.focusAreas)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Deep Analytics")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Regenerate") {
                        analytics = DashboardData.Analytics.alternative
                    }
                }
            }
        }
    }
}

// MARK: - Analytics Overview

struct AnalyticsOverview: View {
    let analytics: DashboardData.Analytics

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Weekly Intelligence", subtitle: analytics.caption)

            VStack(alignment: .leading, spacing: 18) {
                Gauge(value: analytics.sleepScoreAverage / 100.0) {
                    Text("Average Sleep Score")
                } currentValueLabel: {
                    Text("\(Int(analytics.sleepScoreAverage))")
                }
                .gaugeStyle(.accessoryCircular)
                .tint(Gradient(colors: [.accentBlue, .accentPurple]))
                .frame(width: 120, height: 120)
                .frame(maxWidth: .infinity, alignment: .center)

                Divider().background(.white.opacity(0.1))

                ForEach(analytics.distribution) { point in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(point.label)
                                .font(.subheadline)
                                .foregroundStyle(.white)

                            Spacer()

                            Text(point.valueText)
                                .font(.headline)
                                .foregroundStyle(.white)
                        }

                        ProgressView(value: point.progress)
                            .tint(point.tint)
                            .background(
                                Capsule()
                                    .fill(.white.opacity(0.08))
                            )
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(24)
            .glassCard(
                cornerRadius: 28,
                tint: LinearGradient(
                    colors: [.accentBlue.opacity(0.22), .accentPurple.opacity(0.18)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
}

// MARK: - Sleep Quality Chart

struct SleepQualityChart: View {
    let analytics: DashboardData.Analytics

    private let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let scores = [82, 78, 85, 91, 76, 88, 86] // Sample data

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Sleep Score Trend", subtitle: "Daily sleep quality over time")

            VStack(spacing: 16) {
                // Bar Chart
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(0..<7, id: \.self) { index in
                        VStack(spacing: 8) {
                            Text("\(scores[index])")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.7))

                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            scoreColor(scores[index]).opacity(0.8),
                                            scoreColor(scores[index]).opacity(0.4)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: CGFloat(scores[index]) * 1.2)

                            Text(weekDays[index])
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 140)

                Divider().background(.white.opacity(0.1))

                // Summary Stats
                HStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("Average")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                        Text("\(scores.reduce(0, +) / scores.count)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: 4) {
                        Text("Best")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                        Text("\(scores.max() ?? 0)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.accentGreen)
                    }
                    .frame(maxWidth: .infinity)

                    VStack(spacing: 4) {
                        Text("Lowest")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                        Text("\(scores.min() ?? 0)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.accentOrange)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(20)
            .glassCard(
                cornerRadius: 24,
                tint: LinearGradient(
                    colors: [.accentTeal.opacity(0.15), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }

    private func scoreColor(_ score: Int) -> Color {
        if score >= 85 {
            return .accentGreen
        } else if score >= 70 {
            return .accentBlue
        } else {
            return .accentOrange
        }
    }
}

// MARK: - Trend Cards

struct TrendCards: View {
    let trends: [DashboardData.Analytics.Trend]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Key Trends", subtitle: "Correlations surfaced by multi-agent analysis")

            VStack(spacing: 16) {
                ForEach(trends, id: \.id) { trend in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Label(trend.title, systemImage: trend.icon)
                                .foregroundStyle(trend.tint)
                                .font(.headline)

                            Spacer()

                            TrendBadge(trend: trend.trend)
                        }

                        Text(trend.detail)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))

                        Divider().background(.white.opacity(0.08))

                        HStack {
                            Text(trend.context)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.55))
                            Spacer()
                            Label("\(trend.confidence)% confidence", systemImage: "checkmark.seal.fill")
                                .font(.caption2)
                                .foregroundStyle(.accentTeal)
                        }
                    }
                    .padding(20)
                    .glassCard(
                        cornerRadius: 24,
                        tint: LinearGradient(
                            colors: [trend.tint.opacity(0.18), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
            }
        }
    }
}

// MARK: - Focus Areas

struct FocusAreas: View {
    let focusAreas: [DashboardData.Analytics.FocusArea]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Focus Areas", subtitle: "Personalized recommendations for the week")

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 170), spacing: 16)], spacing: 16) {
                ForEach(focusAreas) { area in
                    VStack(alignment: .leading, spacing: 12) {
                        Label {
                            Text(area.title)
                                .font(.headline)
                                .foregroundStyle(.white)
                        } icon: {
                            Image(systemName: area.icon)
                                .foregroundStyle(area.tint)
                        }

                        Text(area.detail)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.7))
                            .lineLimit(4)

                        Spacer(minLength: 0)

                        Button(area.actionLabel) { }
                            .font(.caption)
                            .foregroundStyle(area.tint)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(area.tint.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    .padding(18)
                    .glassCard(
                        cornerRadius: 22,
                        tint: LinearGradient(
                            colors: [area.tint.opacity(0.18), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(minHeight: 160)
                }
            }
        }
    }
}
