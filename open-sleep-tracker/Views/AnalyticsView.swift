//
//  AnalyticsView.swift
//  open-sleep-tracker
//
//  Apple-style minimalist analytics
//

import SwiftUI

// MARK: - Analytics View

struct AnalyticsView: View {
    @State private var analytics = DashboardData.Analytics.sample
    @State private var selectedTimeRange: TimeRange = .week
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case quarter = "Quarter"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Time Range Picker
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.segmented)

                    // Score Overview
                    ScoreOverviewCard(analytics: analytics)

                    // Sleep Quality Chart
                    SleepChartCard()

                    // Key Trends
                    TrendsCard(trends: analytics.trends)

                    // Recommendations
                    RecommendationsCard(focusAreas: analytics.focusAreas)
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Insights")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        analytics = DashboardData.Analytics.alternative
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

// MARK: - Score Overview Card

struct ScoreOverviewCard: View {
    let analytics: DashboardData.Analytics

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Average Score")
                    .font(.headline)
                Spacer()
            }

            // Circular Score
            ZStack {
                Circle()
                    .stroke(Color.appSeparator.opacity(0.3), lineWidth: 16)

                Circle()
                    .trim(from: 0, to: analytics.sleepScoreAverage / 100.0)
                    .stroke(
                        scoreColor(analytics.sleepScoreAverage),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 4) {
                    Text("\(Int(analytics.sleepScoreAverage))")
                        .font(.system(size: 44, weight: .bold, design: .rounded))

                    Text("This Week")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 160, height: 160)

            Divider()

            // Distribution
            VStack(spacing: 12) {
                ForEach(analytics.distribution) { point in
                    HStack {
                        Text(point.label)
                            .font(.subheadline)

                        Spacer()

                        Text(point.valueText)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }

                    ProgressView(value: point.progress)
                        .tint(point.tint)
                }
            }
        }
        .padding(20)
        .background(Color.appSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func scoreColor(_ score: Double) -> Color {
        if score >= 80 { return .green }
        else if score >= 60 { return .orange }
        else { return .red }
    }
}

// MARK: - Sleep Chart Card

struct SleepChartCard: View {
    private let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    private let scores = [82, 78, 85, 91, 76, 88, 86]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Trend")
                .font(.headline)

            // Bar Chart
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(0..<7, id: \.self) { index in
                    VStack(spacing: 8) {
                        Text("\(scores[index])")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(barColor(scores[index]))
                            .frame(height: CGFloat(scores[index]) * 1.2)

                        Text(weekDays[index])
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 140)

            Divider()

            // Summary
            HStack {
                SummaryItem(title: "Average", value: "\(scores.reduce(0, +) / scores.count)", color: .primary)
                Spacer()
                SummaryItem(title: "Best", value: "\(scores.max() ?? 0)", color: .green)
                Spacer()
                SummaryItem(title: "Lowest", value: "\(scores.min() ?? 0)", color: .orange)
            }
        }
        .padding(20)
        .background(Color.appSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func barColor(_ score: Int) -> Color {
        if score >= 85 { return .green }
        else if score >= 70 { return .blue }
        else { return .orange }
    }
}

struct SummaryItem: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Trends Card

struct TrendsCard: View {
    let trends: [DashboardData.Analytics.Trend]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Key Insights")
                .font(.headline)

            VStack(spacing: 12) {
                ForEach(trends, id: \.id) { trend in
                    TrendRow(trend: trend)
                }
            }
        }
    }
}

struct TrendRow: View {
    let trend: DashboardData.Analytics.Trend

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: trend.icon)
                .foregroundStyle(trend.tint)
                .frame(width: 36, height: 36)
                .background(trend.tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(trend.title)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    TrendBadge(trend: trend.trend)
                }

                Text(trend.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(14)
        .background(Color.appSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Recommendations Card

struct RecommendationsCard: View {
    let focusAreas: [DashboardData.Analytics.FocusArea]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recommendations")
                .font(.headline)

            VStack(spacing: 12) {
                ForEach(focusAreas) { area in
                    RecommendationRow(area: area)
                }
            }
        }
    }
}

struct RecommendationRow: View {
    let area: DashboardData.Analytics.FocusArea

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: area.icon)
                .foregroundStyle(area.tint)
                .frame(width: 36, height: 36)
                .background(area.tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(area.title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(area.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(Color.appSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Legacy Support

struct AnalyticsOverview: View {
    let analytics: DashboardData.Analytics

    var body: some View {
        ScoreOverviewCard(analytics: analytics)
    }
}

struct SleepQualityChart: View {
    let analytics: DashboardData.Analytics

    var body: some View {
        SleepChartCard()
    }
}

struct TrendCards: View {
    let trends: [DashboardData.Analytics.Trend]

    var body: some View {
        TrendsCard(trends: trends)
    }
}

struct FocusAreas: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let focusAreas: [DashboardData.Analytics.FocusArea]

    var body: some View {
        RecommendationsCard(focusAreas: focusAreas)
    }
}
