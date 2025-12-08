//
//  DashboardView.swift
//  open-sleep-tracker
//
//  Apple-style minimalist dashboard
//

import SwiftUI

// MARK: - Dashboard Screen

struct DashboardScreen: View {
    @Binding var selectedTab: ContentView.Tab
    @ObservedObject var audioRecorder: AudioRecorder
    @State private var dashboardData = DashboardData.sample
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Sleep Score Card
                    SleepScoreCard(summary: dashboardData.summary)

                    // Quick Actions
                    QuickActionsSection(
                        audioRecorder: audioRecorder,
                        onNavigate: { tab in
                            withAnimation { selectedTab = tab }
                        }
                    )

                    // Today's Metrics
                    MetricsSection(summary: dashboardData.summary)

                    // Insights
                    InsightsSection(insights: dashboardData.insights)

                    // Agent Status
                    AgentSection(agents: dashboardData.agents)
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Sleep")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dashboardData = DashboardData.sampleNextPhase()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
        }
    }
}

// MARK: - Sleep Score Card

struct SleepScoreCard: View {
    let summary: DashboardData.SleepSummary

    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Last Night")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(summary.headline)
                        .font(.title2)
                        .fontWeight(.semibold)

                    HStack(spacing: 4) {
                        Image(systemName: summary.trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                        Text(summary.trendDescription)
                    }
                    .font(.subheadline)
                    .foregroundStyle(summary.trend >= 0 ? .green : .orange)
                }

                Spacer()

                CircularScoreView(score: summary.sleepScore)
            }

            Divider()

            HStack(spacing: 16) {
                QuickStat(icon: "bed.double.fill", title: "Duration", value: summary.formattedDuration, color: .blue)
                QuickStat(icon: "moon.stars.fill", title: "Deep", value: "\(summary.deepSleepPercentage)%", color: .indigo)
                QuickStat(icon: "sparkles", title: "REM", value: "\(summary.remSleepPercentage)%", color: .purple)
            }
        }
        .padding(20)
        .background(Color.appSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct QuickStat: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.headline)
                .fontWeight(.semibold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Quick Actions Section

struct QuickActionsSection: View {
    @ObservedObject var audioRecorder: AudioRecorder
    let onNavigate: (ContentView.Tab) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .padding(.horizontal, 4)

            HStack(spacing: 12) {
                // Start/Stop Recording
                Button {
                    if audioRecorder.isRecording {
                        audioRecorder.stopRecording()
                    } else {
                        audioRecorder.startRecording()
                    }
                } label: {
                    HStack {
                        Image(systemName: audioRecorder.isRecording ? "stop.fill" : "moon.zzz.fill")
                        Text(audioRecorder.isRecording ? "Stop" : "Sleep")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(audioRecorder.isRecording ? Color.orange : Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                // Recordings
                Button {
                    onNavigate(.recordings)
                } label: {
                    HStack {
                        Image(systemName: "waveform")
                        Text("Recordings")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.appSecondaryBackground)
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                // Insights
                Button {
                    onNavigate(.analytics)
                } label: {
                    HStack {
                        Image(systemName: "chart.bar.fill")
                        Text("Insights")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.appSecondaryBackground)
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
    }
}

// MARK: - Metrics Section

struct MetricsSection: View {
    let summary: DashboardData.SleepSummary
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var columns: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible())]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sleep Metrics")
                .font(.headline)
                .padding(.horizontal, 4)

            LazyVGrid(columns: columns, spacing: 12) {
                MetricCard(
                    icon: "bed.double.fill",
                    title: "Total Sleep",
                    value: summary.formattedDuration,
                    subtitle: "Goal: 8h",
                    color: .blue
                )

                MetricCard(
                    icon: "waveform.path.ecg",
                    title: "Snore Events",
                    value: "\(summary.snoreEvents)",
                    subtitle: "Filtered \(summary.filteredPercentage)%",
                    color: .orange
                )

                MetricCard(
                    icon: "moon.stars.fill",
                    title: "Deep Sleep",
                    value: "\(summary.deepSleepPercentage)%",
                    subtitle: "Target: 25%",
                    color: .indigo
                )

                MetricCard(
                    icon: "sparkles",
                    title: "REM Sleep",
                    value: "\(summary.remSleepPercentage)%",
                    subtitle: "Target: 20%",
                    color: .purple
                )
            }
        }
    }
}

struct MetricCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }

            Text(value)
                .font(.title2)
                .fontWeight(.semibold)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(Color.appSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Insights Section

struct InsightsSection: View {
    let insights: [DashboardData.Insight]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights")
                .font(.headline)
                .padding(.horizontal, 4)

            VStack(spacing: 12) {
                ForEach(insights.prefix(3)) { insight in
                    InsightRow(insight: insight)
                }
            }
        }
    }
}

struct InsightRow: View {
    let insight: DashboardData.Insight

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: insight.icon)
                .font(.title3)
                .foregroundStyle(insight.tint)
                .frame(width: 36, height: 36)
                .background(insight.tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(insight.title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(insight.detail)
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

// MARK: - Agent Section

struct AgentSection: View {
    let agents: [DashboardData.Agent]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("AI Agents")
                    .font(.headline)

                Spacer()

                Text("\(agents.filter { $0.state == .running }.count)/\(agents.count) Active")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(agents) { agent in
                        AgentCard(agent: agent)
                    }
                }
            }
        }
    }
}

struct AgentCard: View {
    let agent: DashboardData.Agent

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: agent.icon)
                    .foregroundStyle(agent.tint)

                Spacer()

                StatusIndicator(state: agent.state)
            }

            Text(agent.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)

            Text(agent.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(width: 160)
        .padding(14)
        .background(Color.appSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct StatusIndicator: View {
    let state: DashboardData.Agent.State

    var body: some View {
        Circle()
            .fill(state.color)
            .frame(width: 8, height: 8)
    }
}

// MARK: - Legacy Support Components

struct DashboardHeroCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let summary: DashboardData.SleepSummary

    var body: some View {
        SleepScoreCard(summary: summary)
    }
}

struct DashboardQuickDestination: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let tab: ContentView.Tab
}

struct DashboardQuickNavigation: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let destinations: [DashboardQuickDestination]
    let onSelect: (ContentView.Tab) -> Void

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(destinations) { destination in
                Button {
                    onSelect(destination.tab)
                } label: {
                    HStack {
                        Image(systemName: destination.icon)
                            .foregroundStyle(.blue)
                        Text(destination.title)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(14)
                    .background(Color.appSecondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct DashboardSectionPicker: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selection: DashboardScreen.DashboardSection

    var body: some View {
        Picker("Section", selection: $selection) {
            ForEach(DashboardScreen.DashboardSection.allCases) { section in
                Text(section.title).tag(section)
            }
        }
        .pickerStyle(.segmented)
    }
}

extension DashboardScreen {
    enum DashboardSection: String, CaseIterable, Identifiable {
        case overview, insights, agents

        var id: String { rawValue }
        var title: String {
            switch self {
            case .overview: return "Overview"
            case .insights: return "Insights"
            case .agents: return "Agents"
            }
        }
        var icon: String {
            switch self {
            case .overview: return "rectangle.grid.2x2"
            case .insights: return "chart.bar.doc.horizontal"
            case .agents: return "person.3.fill"
            }
        }
        var subtitle: String {
            switch self {
            case .overview: return "Tonight at a glance"
            case .insights: return "Trends & guidance"
            case .agents: return "Agent network health"
            }
        }
    }
}

// MARK: - Legacy Components (Simplified)

struct AgentSnapshotCard: View {
    let agents: [DashboardData.Agent]
    let onManageAgents: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Agent Status")
                .font(.headline)

            HStack(spacing: 20) {
                StatView(title: "Active", value: "\(agents.filter { $0.state == .running }.count)", color: .green)
                StatView(title: "Syncing", value: "\(agents.filter { $0.state == .syncing }.count)", color: .blue)
                StatView(title: "Attention", value: "\(agents.filter { $0.state == .attention }.count)", color: .orange)
            }

            Button("Manage Agents") {
                onManageAgents()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(16)
        .background(Color.appSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct StatView: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct AgentSnapshotMetric: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color

    var body: some View {
        StatView(title: title, value: value, color: tint)
    }
}

struct HighlightGrid: View {
    let highlights: [DashboardData.Highlight]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(highlights) { highlight in
                HighlightCard(highlight: highlight)
            }
        }
    }
}

struct HighlightCard: View {
    let highlight: DashboardData.Highlight

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: highlight.icon)
                    .foregroundStyle(highlight.tint)
                Spacer()
                TrendBadge(trend: highlight.trend)
            }

            Text(highlight.title)
                .font(.subheadline)
                .fontWeight(.medium)

            Text(highlight.caption)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(14)
        .background(Color.appSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct AgentStatusSection: View {
    let agents: [DashboardData.Agent]

    var body: some View {
        AgentSection(agents: agents)
    }
}

struct LiveSessionControl: View {
    @ObservedObject var audioRecorder: AudioRecorder
    var onStandByTrigger: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            // Recording Button
            Button {
                if audioRecorder.isRecording {
                    audioRecorder.stopRecording()
                } else {
                    audioRecorder.startRecording()
                }
            } label: {
                VStack(spacing: 12) {
                    Image(systemName: audioRecorder.isRecording ? "stop.circle.fill" : "record.circle.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(audioRecorder.isRecording ? .orange : .green)

                    Text(audioRecorder.isRecording ? "Stop Recording" : "Start Sleep Session")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
                .background(Color.appSecondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)

            if audioRecorder.isRecording {
                VStack(spacing: 12) {
                    HStack {
                        Label(audioRecorder.recordingDuration.formattedDurationDescription, systemImage: "clock")
                        Spacer()
                        Label("Recording", systemImage: "waveform")
                            .foregroundStyle(.orange)
                    }
                    .font(.subheadline)

                    if let standByTrigger = onStandByTrigger, DeviceInfo.isIPad {
                        Button {
                            standByTrigger()
                        } label: {
                            Label("Enter StandBy Mode", systemImage: "display")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(16)
                .background(Color.appSecondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }
}

struct TimelineSection: View {
    let events: [DashboardData.SleepEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Timeline")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(events) { event in
                        TimelineEventCard(event: event)
                    }
                }
            }
        }
    }
}

struct TimelineEventCard: View {
    let event: DashboardData.SleepEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(event.timeLabel)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(event.title)
                .font(.subheadline)
                .fontWeight(.medium)

            Text(event.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .frame(width: 150)
        .padding(12)
        .background(Color.appSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
