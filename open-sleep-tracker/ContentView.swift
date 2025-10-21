//
//  ContentView.swift
//  open-sleep-tracker
//
//  Redesigned by Codex on 10/21/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var selectedTab: Tab = .dashboard
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardScreen(audioRecorder: audioRecorder)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.dashboard)
            
            SleepTrackingView(audioRecorder: audioRecorder)
                .tabItem {
                    Label("Sessions", systemImage: "moon.zzz.fill")
                }
                .tag(Tab.sessions)
            
            RecordingsView(audioRecorder: audioRecorder)
                .tabItem {
                    Label("Recordings", systemImage: "waveform")
                }
                .tag(Tab.recordings)
            
            AnalyticsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.xaxis")
                }
                .tag(Tab.analytics)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }
                .tag(Tab.settings)
        }
        .tint(.accentBlue)
    }
    
    enum Tab {
        case dashboard, sessions, recordings, analytics, settings
    }
}

// MARK: - Dashboard

struct DashboardScreen: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @State private var dashboardData = DashboardData.sample
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 24) {
                        DashboardHeroCard(summary: dashboardData.summary)
                        
                        HighlightGrid(highlights: dashboardData.highlights)
                        
                        AgentStatusSection(agents: dashboardData.agents)
                        
                        LiveSessionControl(audioRecorder: audioRecorder)
                        
                        InsightsSection(insights: dashboardData.insights)
                        
                        TimelineSection(events: dashboardData.timeline)
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
}

struct DashboardHeroCard: View {
    let summary: DashboardData.SleepSummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(summary.dateRangeLabel.uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white.opacity(0.6))
                        .tracking(1.1)
                    
                    Text(summary.headline)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
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
            
            Divider().background(.white.opacity(0.1))
            
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
        .glassCard(
            cornerRadius: 28,
            tint: LinearGradient(
                colors: [
                    .accentBlue.opacity(0.45),
                    .accentPurple.opacity(0.3),
                    .black.opacity(0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

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

struct LiveSessionControl: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @State private var animatePulse = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(
                title: "Live Session",
                subtitle: "Audio Classification Agent monitors in real time"
            )
            
            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                        .background(
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color.accentBlue.opacity(0.35),
                                            Color.accentPurple.opacity(0.25),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 140
                                    )
                                )
                        )
                        .overlay {
                            Circle()
                                .stroke(
                                    AngularGradient(
                                        colors: [.accentBlue, .accentPurple, .accentTeal],
                                        center: .center
                                    ),
                                    lineWidth: 2
                                )
                                .opacity(0.6)
                        }
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 12)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.08), lineWidth: 20)
                                .scaleEffect(animatePulse ? 1.15 : 0.9)
                                .opacity(animatePulse ? 0.35 : 0.15)
                                .animation(
                                    .easeInOut(duration: 1.8)
                                        .repeatForever(autoreverses: true),
                                    value: animatePulse
                                )
                        )
                    
                    VStack(spacing: 12) {
                        Image(systemName: audioRecorder.isRecording ? "stop.circle.fill" : "record.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(audioRecorder.isRecording ? Color.accentOrange : Color.accentGreen)
                            .accessibilityHidden(true)
                        
                        Button {
                            toggleRecording()
                        } label: {
                            Text(audioRecorder.isRecording ? "Stop Session" : "Start Sleep Session")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(
                                    Capsule()
                                        .fill(audioRecorder.isRecording ? Color.accentOrange.opacity(0.2) : Color.accentGreen.opacity(0.25))
                                        .overlay(
                                            Capsule()
                                                .stroke(
                                                    audioRecorder.isRecording ? Color.accentOrange.opacity(0.5) : Color.accentGreen.opacity(0.5),
                                                    lineWidth: 1
                                                )
                                        )
                                )
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.plain)
                        
                        Text(audioRecorder.isRecording ? recordingSubtitle : "Audio Classification Agent ready to monitor snoring patterns.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                }
                .frame(height: 240)
                
                if audioRecorder.isRecording {
                    SessionMetrics(duration: audioRecorder.recordingDuration, level: audioRecorder.audioLevel)
                } else {
                    SessionScheduler()
                }
            }
            .padding(24)
            .glassCard(
                cornerRadius: 28,
                tint: LinearGradient(
                    colors: [.accentBlue.opacity(0.2), .accentPurple.opacity(0.25)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .onAppear {
            animatePulse = audioRecorder.isRecording
        }
        .onChange(of: audioRecorder.isRecording) { newValue in
            withAnimation(.easeInOut(duration: 0.8)) {
                animatePulse = newValue
            }
        }
    }
    
    private var recordingSubtitle: String {
        "Monitoring snore intensity, filtering noise, and updating Sleep Pattern Analysis Agent."
    }
    
    private func toggleRecording() {
        if audioRecorder.isRecording {
            audioRecorder.stopRecording()
        } else {
            audioRecorder.startRecording()
        }
    }
}

struct SessionMetrics: View {
    let duration: TimeInterval
    let level: Float
    
    var body: some View {
        HStack(spacing: 16) {
            MetricPill(
                title: "Elapsed",
                value: duration.formattedDurationDescription,
                icon: "clock.fill"
            )
            
            MetricPill(
                title: "Snore Activity",
                value: "\(Int(level * 100))%",
                icon: "waveform",
                tint: .accentOrange
            )
            
            MetricPill(
                title: "Confidence",
                value: level > 0.6 ? "High" : "Moderate",
                icon: "brain.head.profile",
                tint: .accentTeal
            )
        }
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }
}

struct SessionScheduler: View {
    private let tonight = DashboardData.SessionSchedule.sample
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Tonight's Plan", subtitle: "Optimized by Sleep Pattern Analysis Agent")
            
            ForEach(tonight.checkpoints) { checkpoint in
                HStack(alignment: .top, spacing: 12) {
                    VStack {
                        Circle()
                            .fill(checkpoint.tint)
                            .frame(width: 10, height: 10)
                        if checkpoint.id != tonight.checkpoints.last?.id {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(.white.opacity(0.12))
                                .frame(width: 2, height: 32)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(checkpoint.timeLabel)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                            
                            Spacer()
                            
                            Text(checkpoint.phase)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.6))
                        }
                        
                        Text(checkpoint.description)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.65))
                    }
                }
                .padding(.vertical, 4)
            }
        }
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

// MARK: - Sleep Tracking

struct SleepTrackingView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @State private var schedule = DashboardData.SessionSchedule.sample
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 24) {
                        ScheduleOverview(schedule: schedule)
                        
                        LiveSessionControl(audioRecorder: audioRecorder)
                        
                        RoutineChecklist(actions: schedule.routines)
                        
                        EnvironmentSection(readings: schedule.environmentReadings)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Sleep Sessions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Optimize") {
                        schedule = DashboardData.SessionSchedule.optimized
                    }
                }
            }
        }
    }
}

struct ScheduleOverview: View {
    let schedule: DashboardData.SessionSchedule
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Tonight's Schedule",
                subtitle: "Synced via Data Synchronization Agent"
            )
            
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Label(schedule.sleepWindow, systemImage: "calendar.badge.clock")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Spacer()
                    BadgeView(text: schedule.focus, icon: "target", color: .accentPurple)
                }
                
                Text(schedule.summary)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                
                Divider().background(.white.opacity(0.1))
                
                ForEach(schedule.checkpoints) { checkpoint in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: checkpoint.icon)
                            .foregroundStyle(checkpoint.tint)
                            .frame(width: 28, height: 28)
                            .background(checkpoint.tint.opacity(0.18))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(checkpoint.phase)
                                    .font(.footnote)
                                    .foregroundStyle(.white.opacity(0.6))
                                Spacer()
                                Text(checkpoint.timeLabel)
                                    .font(.footnote)
                                    .foregroundStyle(.white)
                            }
                            
                            Text(checkpoint.description)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(20)
            .glassCard(
                cornerRadius: 26,
                tint: LinearGradient(
                    colors: [.accentTeal.opacity(0.18), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
}

struct RoutineChecklist: View {
    struct ChecklistItem: Identifiable {
        let id = UUID()
        let title: String
        let detail: String
        let icon: String
        let tint: Color
    }
    
    let actions: [DashboardData.SessionSchedule.Routine]
    @State private var completed: Set<UUID> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Pre-Sleep Routine", subtitle: "Guided by Notification Agent")
            
            VStack(spacing: 12) {
                ForEach(actions) { action in
                    Button {
                        toggle(action.id)
                    } label: {
                        HStack(alignment: .center, spacing: 14) {
                            Image(systemName: action.icon)
                                .foregroundStyle(action.tint)
                                .frame(width: 28, height: 28)
                                .background(action.tint.opacity(0.18))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(action.title)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                
                                Text(action.detail)
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                            
                            Spacer()
                            
                            Image(systemName: completed.contains(action.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(action.tint)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                    }
                    .buttonStyle(.plain)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(.white.opacity(0.04))
                    )
                }
            }
            .padding(18)
            .glassCard(
                cornerRadius: 24,
                tint: LinearGradient(
                    colors: [.accentOrange.opacity(0.15), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }
    
    private func toggle(_ id: UUID) {
        if completed.contains(id) {
            completed.remove(id)
        } else {
            completed.insert(id)
        }
    }
}

struct EnvironmentSection: View {
    let readings: [DashboardData.SessionSchedule.EnvironmentReading]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(
                title: "Environment Readiness",
                subtitle: "Tracked with StandBy & Health Integration Agents"
            )
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 16)], spacing: 16) {
                ForEach(readings) { reading in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: reading.icon)
                                .foregroundStyle(reading.tint)
                            
                            Spacer()
                            
                            BadgeView(text: reading.status, icon: reading.statusIcon, color: reading.tint)
                        }
                        
                        Text(reading.title)
                            .font(.headline)
                            .foregroundStyle(.white)
                        
                        Text(reading.value)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        
                        Text(reading.detail)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    .padding(20)
                    .glassCard(
                        cornerRadius: 22,
                        tint: LinearGradient(
                            colors: [reading.tint.opacity(0.18), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                }
            }
        }
    }
}

// MARK: - Analytics

struct AnalyticsView: View {
    @State private var analytics = DashboardData.Analytics.sample
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 24) {
                        AnalyticsOverview(analytics: analytics)
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

struct TrendCards: View {
    let trends: [DashboardData.Analytics.Trend]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Key Trends", subtitle: "Correlations surfaced by multi-agent analysis")
            
            VStack(spacing: 16) {
                ForEach(trends) { trend in
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
                            Label("\(trend.confidence%) confidence", systemImage: "checkmark.seal.fill")
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

// MARK: - Settings

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var healthSyncEnabled = true
    @State private var standbyWidgetsEnabled = true
    @State private var advancedMode = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppBackgroundView()
                
                List {
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
                    
                    Section("Support") {
                        Label("Help & Documentation", systemImage: "questionmark.circle")
                        Label("Feedback", systemImage: "bubble.left.and.bubble.right")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
        }
    }
}

struct AgentDetailSettingsView: View {
    @State private var audioSensitivity: Double = 0.65
    @State private var snoreThreshold: Double = 0.45
    @State private var patternLookback: Int = 14
    @State private var autoModelUpdates = true
    
    var body: some View {
        Form {
            Section("Audio Classification Agent") {
                Slider(value: $audioSensitivity, in: 0.2...1.0) {
                    Text("Sensitivity")
                }
                
                Slider(value: $snoreThreshold, in: 0.1...0.9) {
                    Text("Snore Threshold")
                }
                
                Toggle("Auto-update Models", isOn: $autoModelUpdates)
            }
            
            Section("Sleep Pattern Analysis Agent") {
                Stepper(value: $patternLookback, in: 7...60, step: 7) {
                    Text("Historical Lookback: \(patternLookback) days")
                }
            }
        }
        .navigationTitle("Agent Configurations")
    }
}

struct PrivacyCenterView: View {
    var body: some View {
        Form {
            Section("Data Transparency") {
                Label("On-device Processing", systemImage: "cpu")
                Label("Secure Enclave Enabled", systemImage: "lock.shield")
                Label("Encrypted Cloud Sync", systemImage: "icloud.and.arrow.up")
            }
            
            Section("Permissions") {
                Label("Health Data: Authorized", systemImage: "heart.fill")
                Label("Microphone Access: Granted", systemImage: "mic.fill")
                Label("Notifications: Scheduled", systemImage: "bell.badge")
            }
        }
        .navigationTitle("Privacy Center")
    }
}

// MARK: - Shared Building Blocks & Models

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

struct AppBackgroundView: View {
    @State private var animate = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.04, green: 0.05, blue: 0.14),
                Color(red: 0.06, green: 0.04, blue: 0.18),
                Color(red: 0.03, green: 0.08, blue: 0.2)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            RadialGradient(
                colors: [
                    Color.accentBlue.opacity(0.35),
                    Color.accentPurple.opacity(0.2),
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
                    .white.opacity(0.05),
                    .clear,
                    .accentPurple.opacity(0.08)
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

struct DashboardData {
    struct SleepSummary {
        let headline: String
        let dateRangeLabel: String
        let totalSleep: TimeInterval
        let snoreEvents: Int
        let filteredPercentage: Int
        let deepSleepPercentage: Int
        let remSleepPercentage: Int
        let trend: Double
        let sleepScore: Int
        
        var formattedDuration: String {
            totalSleep.formattedDurationDescription
        }
        
        var trendDescription: String {
            trend >= 0 ? "Sleep score up \(Int(trend))% vs last week" : "Sleep score down \(Int(abs(trend)))% vs last week"
        }
    }
    
    struct Highlight: Identifiable {
        let id = UUID()
        let title: String
        let caption: String
        let icon: String
        let tint: Color
        let trend: Trend
    }
    
    enum Trend {
        case up(Int)
        case down(Int)
        case steady
    }
    
    struct Agent: Identifiable {
        enum State {
            case running, syncing, idle, attention
            
            var label: String {
                switch self {
                case .running: return "Active"
                case .syncing: return "Syncing"
                case .idle: return "Idle"
                case .attention: return "Action Needed"
                }
            }
            
            var icon: String {
                switch self {
                case .running: return "sparkles"
                case .syncing: return "arrow.triangle.2.circlepath"
                case .idle: return "pause.circle"
                case .attention: return "exclamationmark.triangle.fill"
                }
            }
            
            var color: Color {
                switch self {
                case .running: return .accentGreen
                case .syncing: return .accentBlue
                case .idle: return .white.opacity(0.6)
                case .attention: return .accentOrange
                }
            }
        }
        
        let id = UUID()
        let name: String
        let description: String
        let icon: String
        let tint: Color
        let state: State
    }
    
    struct Insight: Identifiable {
        struct Action {
            let label: String
        }
        
        let id = UUID()
        let title: String
        let detail: String
        let icon: String
        let tint: Color
        let action: Action?
    }
    
    struct SleepEvent: Identifiable {
        let id = UUID()
        let timeLabel: String
        let title: String
        let description: String
        let intensity: Int
        let tint: Color
        let agentLabel: String
        let progress: Double
        let agentState: Agent.State
        
        var agentLabelShort: String {
            agentLabel
        }
    }
    
    struct SessionSchedule {
        struct Checkpoint: Identifiable {
            let id = UUID()
            let timeLabel: String
            let phase: String
            let description: String
            let icon: String
            let tint: Color
        }
        
        struct Routine: Identifiable {
            let id = UUID()
            let title: String
            let detail: String
            let icon: String
            let tint: Color
        }
        
        struct EnvironmentReading: Identifiable {
            let id = UUID()
            let title: String
            let value: String
            let detail: String
            let icon: String
            let status: String
            let statusIcon: String
            let tint: Color
        }
        
        let sleepWindow: String
        let summary: String
        let focus: String
        let checkpoints: [Checkpoint]
        let routines: [Routine]
        let environmentReadings: [EnvironmentReading]
    }
    
    struct Analytics {
        struct DistributionPoint: Identifiable {
            let id = UUID()
            let label: String
            let valueText: String
            let progress: Double
            let tint: Color
        }
        
        struct Trend: Identifiable {
            let id = UUID()
            let title: String
            let detail: String
            let icon: String
            let tint: Color
            let trend: DashboardData.Trend
            let context: String
            let confidence: Int
        }
        
        struct FocusArea: Identifiable {
            let id = UUID()
            let title: String
            let detail: String
            let icon: String
            let tint: Color
            let actionLabel: String
        }
        
        let sleepScoreAverage: Double
        let caption: String
        let distribution: [DistributionPoint]
        let trends: [Trend]
        let focusAreas: [FocusArea]
    }
    
    let summary: SleepSummary
    let highlights: [Highlight]
    let agents: [Agent]
    let insights: [Insight]
    let timeline: [SleepEvent]
    let schedule: SessionSchedule
    let analytics: Analytics
    
    static let sample: DashboardData = {
        DashboardData(
            summary: SleepSummary(
                headline: "Rested & Recovered",
                dateRangeLabel: "Oct 20 → Oct 21",
                totalSleep: 7 * 3600 + 42 * 60,
                snoreEvents: 12,
                filteredPercentage: 82,
                deepSleepPercentage: 27,
                remSleepPercentage: 19,
                trend: 12,
                sleepScore: 88
            ),
            highlights: [
                Highlight(
                    title: "Snore intensity down",
                    caption: "Audio Classification Agent reduced false positives by refining thresholds.",
                    icon: "waveform.badge.minus",
                    tint: .accentGreen,
                    trend: .up(18)
                ),
                Highlight(
                    title: "Heart rate coherence",
                    caption: "Health Integration Agent detected steady HRV patterns during deep sleep.",
                    icon: "heart.fill",
                    tint: .accentTeal,
                    trend: .steady
                ),
                Highlight(
                    title: "Sleep schedule compliance",
                    caption: "Notification Agent maintained 92% adherence to your 11pm wind-down routine.",
                    icon: "bell.badge",
                    tint: .accentPurple,
                    trend: .up(9)
                ),
                Highlight(
                    title: "StandBy ambient success",
                    caption: "StandBy Intelligence Agent kept display luminosity optimal all night.",
                    icon: "display",
                    tint: .accentBlue,
                    trend: .down(3)
                )
            ],
            agents: [
                Agent(
                    name: "Audio Classification",
                    description: "Real-time snore detection with MLSoundClassifier tuned for your profile.",
                    icon: "waveform.circle.fill",
                    tint: .accentGreen,
                    state: .running
                ),
                Agent(
                    name: "Sleep Pattern Analysis",
                    description: "Predicts nightly quality using 60-day trend modeling and time-series analysis.",
                    icon: "chart.xyaxis.line",
                    tint: .accentTeal,
                    state: .running
                ),
                Agent(
                    name: "Health Integration",
                    description: "Syncs heart, respiratory, and motion signals via HealthKit and Apple Watch.",
                    icon: "heart.text.square",
                    tint: .accentPurple,
                    state: .syncing
                ),
                Agent(
                    name: "Intelligent Notifications",
                    description: "Delivers adaptive reminders, wake windows, and StandBy widgets.",
                    icon: "bell.badge.waveform.fill",
                    tint: .accentBlue,
                    state: .running
                ),
                Agent(
                    name: "Data Synchronization",
                    description: "CloudKit + Core Data pipeline with conflict resolution across devices.",
                    icon: "arrow.triangle.branch",
                    tint: .accentOrange,
                    state: .attention
                ),
                Agent(
                    name: "StandBy Intelligence",
                    description: "Curates nightstand display with ambient cues and sleep progress.",
                    icon: "display",
                    tint: .accentPurple,
                    state: .idle
                )
            ],
            insights: [
                Insight(
                    title: "Wind-down earlier tonight",
                    detail: "Falling asleep 20 minutes earlier boosts predicted sleep quality by 9%.",
                    icon: "sparkles",
                    tint: .accentGreen,
                    action: .init(label: "Add to schedule")
                ),
                Insight(
                    title: "Enable AirPlay white noise",
                    detail: "Audio Classification Agent suggests a 35 dB background noise to reduce snore probability.",
                    icon: "speaker.wave.2.circle",
                    tint: .accentBlue,
                    action: .init(label: "Start playback")
                ),
                Insight(
                    title: "Consider quieter bedding",
                    detail: "Movement spikes correlate with snore clusters. Try the \"CalmNight\" pillow preset.",
                    icon: "bed.double.circle.fill",
                    tint: .accentPurple,
                    action: nil
                )
            ],
            timeline: [
                SleepEvent(
                    timeLabel: "11:24 PM",
                    title: "Session Started",
                    description: "Audio Classification Agent calibrated to current room acoustics.",
                    intensity: 1,
                    tint: .accentBlue,
                    agentLabel: "Data Sync → CloudKit",
                    progress: 0.12,
                    agentState: .running
                ),
                SleepEvent(
                    timeLabel: "12:10 AM",
                    title: "Light snoring detected",
                    description: "Low-intensity snore pattern categorized as Type A. Filtered 3 ambient noises.",
                    intensity: 3,
                    tint: .accentOrange,
                    agentLabel: "Audio Agent",
                    progress: 0.3,
                    agentState: .running
                ),
                SleepEvent(
                    timeLabel: "02:08 AM",
                    title: "Deep sleep achieved",
                    description: "Sleep Pattern Analysis Agent validated >25% deep sleep streak.",
                    intensity: 4,
                    tint: .accentTeal,
                    agentLabel: "Sleep Pattern",
                    progress: 0.65,
                    agentState: .running
                ),
                SleepEvent(
                    timeLabel: "04:46 AM",
                    title: "High snore cluster",
                    description: "Triggered StandBy ambient dimming and recorded for personalization.",
                    intensity: 5,
                    tint: .accentOrange,
                    agentLabel: "Audio + StandBy",
                    progress: 0.88,
                    agentState: .attention
                ),
                SleepEvent(
                    timeLabel: "06:45 AM",
                    title: "Smart wake suggestion",
                    description: "Notification Agent queued gentle wake within 10-minute light-sleep window.",
                    intensity: 2,
                    tint: .accentPurple,
                    agentLabel: "Notification Agent",
                    progress: 1.0,
                    agentState: .running
                )
            ],
            schedule: SessionSchedule.sample,
            analytics: Analytics.sample
        )
    }()
    
    static func sampleNextPhase() -> DashboardData {
        .init(
            summary: SleepSummary(
                headline: "Recovery Mode",
                dateRangeLabel: "Oct 21 → Oct 22",
                totalSleep: 6 * 3600 + 58 * 60,
                snoreEvents: 18,
                filteredPercentage: 76,
                deepSleepPercentage: 22,
                remSleepPercentage: 17,
                trend: -6,
                sleepScore: 74
            ),
            highlights: sample.highlights.shuffled(),
            agents: sample.agents.shuffled(),
            insights: sample.insights.shuffled(),
            timeline: sample.timeline.shuffled(),
            schedule: SessionSchedule.optimized,
            analytics: Analytics.alternative
        )
    }
}

extension DashboardData.SessionSchedule {
    static let sample: DashboardData.SessionSchedule = DashboardData.SessionSchedule(
        sleepWindow: "11:00 PM – 6:30 AM",
        summary: "Health Integration Agent aligned your target sleep with heart rate recovery windows.",
        focus: "Recovery",
        checkpoints: [
            .init(timeLabel: "10:30 PM", phase: "Wind-down", description: "Enable StandBy ambient display and start Calm Breathing routine.", icon: "wind", tint: .accentPurple),
            .init(timeLabel: "11:00 PM", phase: "Lights out", description: "Audio Classification Agent calibrates and begins live monitoring.", icon: "moon.stars.fill", tint: .accentBlue),
            .init(timeLabel: "3:30 AM", phase: "Snore review", description: "Agent will adjust thresholds if snore intensity >60%.", icon: "waveform.path.ecg", tint: .accentOrange),
            .init(timeLabel: "6:10 AM", phase: "Smart wake", description: "Wake suggestion triggered at optimal light-sleep phase.", icon: "alarm", tint: .accentGreen)
        ],
        routines: [
            .init(title: "Hydration check", detail: "Drink water to stabilize respiratory patterns.", icon: "drop.fill", tint: .accentTeal),
            .init(title: "Activate white noise", detail: "Turn on fan or AirPlay ambient noise at 35 dB.", icon: "speaker.wave.2", tint: .accentBlue),
            .init(title: "Place Apple Watch", detail: "Ensure watch is charging for overnight metrics.", icon: "applewatch.watchface", tint: .accentPurple)
        ],
        environmentReadings: [
            .init(title: "Bedroom Temp", value: "67°F", detail: "Ideal range for reduced snoring.", icon: "thermometer.medium", status: "Optimal", statusIcon: "checkmark.circle", tint: .accentGreen),
            .init(title: "Ambient Noise", value: "28 dB", detail: "Quiet; white noise optional.", icon: "ear.fill", status: "Stable", statusIcon: "waveform", tint: .accentBlue),
            .init(title: "Air Quality", value: "AQI 12", detail: "Low irritants detected.", icon: "leaf", status: "Clear", statusIcon: "leaf.fill", tint: .accentTeal)
        ]
    )
    
    static let optimized: DashboardData.SessionSchedule = DashboardData.SessionSchedule(
        sleepWindow: "10:45 PM – 6:15 AM",
        summary: "Adjusted earlier bedtime to improve deep sleep accumulation.",
        focus: "Deep Sleep",
        checkpoints: sample.checkpoints.shuffled(),
        routines: sample.routines.shuffled(),
        environmentReadings: sample.environmentReadings
    )
}

extension DashboardData.Analytics {
    static let sample: DashboardData.Analytics = DashboardData.Analytics(
        sleepScoreAverage: 86,
        caption: "Week of Oct 15 – Oct 21",
        distribution: [
            .init(label: "Deep Sleep", valueText: "26%", progress: 0.26, tint: .accentTeal),
            .init(label: "REM Sleep", valueText: "19%", progress: 0.19, tint: .accentPurple),
            .init(label: "Snore-free", valueText: "78%", progress: 0.78, tint: .accentGreen)
        ],
        trends: [
            .init(
                title: "Evening caffeine impact",
                detail: "Snore events increased 24% on days with caffeine past 3 PM.",
                icon: "cup.and.saucer.fill",
                tint: .accentOrange,
                trend: .down(24),
                context: "Audio Classification Agent",
                confidence: 82
            ),
            .init(
                title: "Movement vs. snore clusters",
                detail: "StandBy Agent detected motion spikes preceding 62% of snore clusters.",
                icon: "figure.walk.motion",
                tint: .accentBlue,
                trend: .steady,
                context: "StandBy Intelligence",
                confidence: 74
            )
        ],
        focusAreas: [
            .init(
                title: "Evening routine",
                detail: "Introduce 10-min meditation before bedtime to lower snore intensity.",
                icon: "person.sitting",
                tint: .accentPurple,
                actionLabel: "Add meditation"
            ),
            .init(
                title: "Air quality",
                detail: "Open window 10 minutes pre-sleep; reduces snore probability by 12%.",
                icon: "wind",
                tint: .accentTeal,
                actionLabel: "Set reminder"
            )
        ]
    )
    
    static let alternative: DashboardData.Analytics = DashboardData.Analytics(
        sleepScoreAverage: 79,
        caption: "Week of Oct 22 – Oct 28",
        distribution: sample.distribution.reversed(),
        trends: sample.trends.reversed(),
        focusAreas: sample.focusAreas.reversed()
    )
}

// MARK: - Utils

extension TimeInterval {
    var formattedDurationDescription: String {
        let totalMinutes = Int(self) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return "\(hours)h \(minutes)m"
    }
}

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

extension Color {
    static let accentBlue = Color(red: 0.38, green: 0.55, blue: 0.97)
    static let accentPurple = Color(red: 0.67, green: 0.44, blue: 0.98)
    static let accentGreen = Color(red: 0.3, green: 0.84, blue: 0.6)
    static let accentOrange = Color(red: 0.98, green: 0.54, blue: 0.2)
    static let accentTeal = Color(red: 0.32, green: 0.82, blue: 0.86)
}

#Preview {
    ContentView()
}
