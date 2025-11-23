//
//  DashboardView.swift
//  open-sleep-tracker
//
//  Created by AI Agent on 11/22/25.
//

import SwiftUI

// MARK: - Dashboard Screen

struct DashboardScreen: View {
    @Binding var selectedTab: ContentView.Tab
    @ObservedObject var audioRecorder: AudioRecorder
    @State private var dashboardData = DashboardData.sample
    @State private var selectedSection: DashboardSection = .overview

    enum DashboardSection: String, CaseIterable, Identifiable {
        case overview
        case insights
        case agents

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

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()

                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 24) {
                        DashboardHeroCard(summary: dashboardData.summary)

                        DashboardQuickNavigation(
                            destinations: quickDestinations,
                            onSelect: { tab in
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedTab = tab
                                }
                            }
                        )

                        DashboardSectionPicker(selection: $selectedSection)

                        sectionContent
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Sleep Intelligence")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dashboardData = DashboardData.sampleNextPhase()
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                    .accessibilityLabel("Refresh sample data")
                }
            }
        }
    }

    private var quickDestinations: [DashboardQuickDestination] {
        [
            .init(
                title: "Sleep Sessions",
                subtitle: "Run overnight monitoring",
                icon: "moon.zzz.fill",
                tab: .sessions
            ),
            .init(
                title: "Recordings",
                subtitle: "Review captured audio",
                icon: "waveform",
                tab: .recordings
            ),
            .init(
                title: "Insights",
                subtitle: "Deep-dive analytics",
                icon: "chart.bar.xaxis",
                tab: .analytics
            ),
            .init(
                title: "Settings",
                subtitle: "Agent preferences & health",
                icon: "slider.horizontal.3",
                tab: .settings
            )
        ]
    }

    @ViewBuilder
    private var sectionContent: some View {
        switch selectedSection {
        case .overview:
            VStack(spacing: 20) {
                HighlightGrid(highlights: dashboardData.highlights)
                LiveSessionControl(audioRecorder: audioRecorder)
            }
        case .insights:
            VStack(spacing: 20) {
                InsightsSection(insights: dashboardData.insights)
                TimelineSection(events: dashboardData.timeline)
            }
        case .agents:
            VStack(spacing: 20) {
                AgentStatusSection(agents: dashboardData.agents)
                AgentSnapshotCard(agents: dashboardData.agents) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedTab = .settings
                    }
                }
            }
        }
    }
}

// MARK: - Dashboard Components

struct DashboardHeroCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let summary: DashboardData.SleepSummary

    var body: some View {
        let theme = themeManager.selectedTheme

        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(summary.dateRangeLabel.uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(theme.textSecondary)
                        .tracking(1.1)

                    Text(summary.headline)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.textPrimary)

                    Label {
                        Text(summary.trendDescription)
                            .font(.footnote)
                            .foregroundColor(summary.trend >= 0 ? .accentGreen : .accentOrange)
                    } icon: {
                        Image(systemName: summary.trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(summary.trend >= 0 ? Color.accentGreen.opacity(0.2) : Color.accentOrange.opacity(0.2))
                    .clipShape(Capsule())
                }

                Spacer()

                CircularScoreView(score: summary.sleepScore)
            }

            Divider().background(theme.textTertiary)

            Grid(horizontalSpacing: 16, verticalSpacing: 16) {
                GridRow {
                    MetricTile(title: "Total Sleep", value: summary.formattedDuration, caption: "Goal 8h", icon: "bed.double.fill")
                    MetricTile(title: "Snore Events", value: "\(summary.snoreEvents)", caption: "Filtered \(summary.filteredPercentage)%", icon: "waveform.path.ecg")
                }

                GridRow {
                    MetricTile(title: "Deep Sleep", value: "\(summary.deepSleepPercentage)%", caption: "Target 25%", icon: "sparkles")
                    MetricTile(title: "REM Sleep", value: "\(summary.remSleepPercentage)%", caption: "Target 20%", icon: "moon.stars.fill")
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [
                                    theme.accentColor.opacity(0.3),
                                    theme.secondaryAccent.opacity(0.2),
                                    .clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(theme.accentColor.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        .animation(.easeInOut(duration: 0.3), value: theme)
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
    let destinations: [DashboardQuickDestination]
    let onSelect: (ContentView.Tab) -> Void

    var body: some View {
        let theme = themeManager.selectedTheme

        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Quick Navigation",
                subtitle: "Open focused screens for deeper control"
            )

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(destinations) { destination in
                    Button {
                        onSelect(destination.tab)
                    } label: {
                        VStack(alignment: .leading, spacing: 12) {
                            Image(systemName: destination.icon)
                                .font(.title3)
                                .foregroundStyle(theme.accentColor)
                                .padding(12)
                                .background(theme.accentColor.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 14))

                            Spacer(minLength: 0)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(destination.title)
                                    .font(.headline)
                                    .foregroundStyle(theme.textPrimary)

                                Text(destination.subtitle)
                                    .font(.caption)
                                    .foregroundStyle(theme.textSecondary)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .frame(maxWidth: .infinity, minHeight: 130, alignment: .leading)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(theme.cardBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 22)
                                        .stroke(theme.accentColor.opacity(0.1), lineWidth: 1)
                                )
                        )
                        .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(destination.title)
                    .accessibilityHint(destination.subtitle)
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: theme)
    }
}

struct DashboardSectionPicker: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selection: DashboardScreen.DashboardSection

    var body: some View {
        let theme = themeManager.selectedTheme

        VStack(alignment: .leading, spacing: 12) {
            Text("Focus Area")
                .font(.headline)
                .foregroundStyle(theme.textPrimary)

            Picker("Focus Area", selection: $selection) {
                ForEach(DashboardScreen.DashboardSection.allCases) { section in
                    Text(section.title)
                        .tag(section)
                }
            }
            .pickerStyle(.segmented)

            Text(selection.subtitle)
                .font(.caption)
                .foregroundStyle(theme.textSecondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(theme.accentColor.opacity(0.12), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
        .animation(.easeInOut(duration: 0.3), value: theme)
    }
}

struct AgentSnapshotCard: View {
    let agents: [DashboardData.Agent]
    let onManageAgents: () -> Void

    private var activeCount: Int {
        agents.filter { $0.state == .running }.count
    }

    private var syncingCount: Int {
        agents.filter { $0.state == .syncing }.count
    }

    private var attentionCount: Int {
        agents.filter { $0.state == .attention }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Agent Coverage Overview")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
            }

            HStack(spacing: 14) {
                AgentSnapshotMetric(title: "Active", value: "\(activeCount)", icon: "sparkles", tint: .accentGreen)
                AgentSnapshotMetric(title: "Syncing", value: "\(syncingCount)", icon: "arrow.triangle.2.circlepath", tint: .accentBlue)
                AgentSnapshotMetric(title: "Attention", value: "\(attentionCount)", icon: "exclamationmark.triangle.fill", tint: .accentOrange)
            }

            Text("Manage agent behavior, notifications, and privacy controls in Settings when you need deeper adjustments.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))

            Button("Manage Agents in Settings") {
                onManageAgents()
            }
            .buttonStyle(.borderedProminent)
            .tint(.accentBlue.opacity(0.8))
        }
        .padding(20)
        .glassCard(
            cornerRadius: 24,
            tint: LinearGradient(
                colors: [Color.white.opacity(0.05), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            shadowColor: .black.opacity(0.2)
        )
    }
}

struct AgentSnapshotMetric: View {
    let title: String
    let value: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(tint)

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color.white.opacity(0.08))
        )
    }
}

struct HighlightGrid: View {
    let highlights: [DashboardData.Highlight]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Highlights", subtitle: "Agent-generated quick updates")

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(highlights) { highlight in
                    HighlightCard(highlight: highlight)
                }
            }
        }
    }
}

struct HighlightCard: View {
    let highlight: DashboardData.Highlight

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: highlight.icon)
                    .font(.title3)
                    .foregroundStyle(highlight.tint)
                    .padding(12)
                    .background(highlight.tint.opacity(0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                Spacer()

                TrendBadge(trend: highlight.trend)
            }

            Text(highlight.title)
                .font(.headline)
                .foregroundStyle(.white)

            Text(highlight.caption)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
                .lineLimit(3)
        }
        .padding(20)
        .glassCard(
            cornerRadius: 22,
            tint: LinearGradient(
                colors: [highlight.tint.opacity(0.15), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            shadowColor: highlight.tint.opacity(0.2)
        )
    }
}

struct AgentStatusSection: View {
    let agents: [DashboardData.Agent]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "AI Agent Network",
                subtitle: "Status across audio, sleep, health, and notifications"
            )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(agents) { agent in
                        AgentCard(agent: agent)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }
}

struct AgentCard: View {
    let agent: DashboardData.Agent

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text(agent.name)
                    .font(.headline)
                    .foregroundStyle(.white)
            } icon: {
                Image(systemName: agent.icon)
                    .foregroundStyle(agent.tint)
            }
            .labelStyle(.iconLeading)

            Text(agent.description)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
                .lineLimit(3)

            Spacer(minLength: 0)

            HStack {
                StatusPill(state: agent.state)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .frame(width: 220, height: 160)
        .padding(20)
        .glassCard(
            cornerRadius: 24,
            tint: LinearGradient(
                colors: [agent.tint.opacity(0.2), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            shadowColor: agent.tint.opacity(0.25)
        )
    }
}

struct InsightsSection: View {
    let insights: [DashboardData.Insight]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "AI Insights", subtitle: "Multi-agent guidance tuned to your sleep goals")

            VStack(alignment: .leading, spacing: 12) {
                ForEach(insights) { insight in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 12) {
                            Image(systemName: insight.icon)
                                .font(.title3)
                                .foregroundStyle(insight.tint)
                                .frame(width: 36, height: 36)
                                .background(insight.tint.opacity(0.18))
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(insight.title)
                                    .font(.headline)
                                    .foregroundStyle(.white)

                                Text(insight.detail)
                                    .font(.subheadline)
                                    .foregroundStyle(.white.opacity(0.7))
                                    .lineLimit(3)
                            }

                            Spacer()
                        }

                        if let action = insight.action {
                            Divider().background(.white.opacity(0.08))

                            Button(action.label) { }
                                .buttonStyle(.borderedProminent)
                                .tint(insight.tint.opacity(0.8))
                        }
                    }
                    .padding(18)
                    .glassCard(
                        cornerRadius: 22,
                        tint: LinearGradient(
                            colors: [insight.tint.opacity(0.15), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        shadowColor: insight.tint.opacity(0.2)
                    )
                }
            }
        }
    }
}

struct TimelineSection: View {
    let events: [DashboardData.SleepEvent]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Night Timeline",
                subtitle: "Annotated by Audio Classification & StandBy Agents"
            )

            VStack(alignment: .leading, spacing: 12) {
                ProgressView(value: events.last?.progress ?? 1.0)
                    .tint(.accentBlue)
                    .background(
                        Capsule()
                            .fill(.white.opacity(0.1))
                    )
                    .frame(height: 6)
                    .clipShape(Capsule())

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(events) { event in
                            TimelineEventCard(event: event)
                        }
                    }
                }
            }
            .padding(20)
            .glassCard(
                cornerRadius: 26,
                tint: LinearGradient(
                    colors: [.accentPurple.opacity(0.18), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
}

struct TimelineEventCard: View {
    let event: DashboardData.SleepEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(event.timeLabel)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.65))
                Spacer()
                StatusPill(state: event.agentState)
            }

            Text(event.title)
                .font(.headline)
                .foregroundStyle(.white)

            Text(event.description)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.65))
                .lineLimit(3)

            Spacer(minLength: 0)

            HStack {
                ForEach(0..<5) { index in
                    Capsule()
                        .fill(event.tint.opacity(index < event.intensity ? 0.8 : 0.25))
                        .frame(width: 8, height: CGFloat(8 + index * 4))
                }

                Spacer()

                Text(event.agentLabel)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .frame(width: 200, height: 160)
        .padding(18)
        .glassCard(
            cornerRadius: 20,
            tint: LinearGradient(
                colors: [event.tint.opacity(0.22), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            shadowColor: event.tint.opacity(0.25)
        )
    }
}
