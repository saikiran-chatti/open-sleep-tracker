//
//  SleepTrackingView.swift
//  open-sleep-tracker
//
//  Created by AI Agent on 11/22/25.
//

import SwiftUI

// MARK: - Sleep Tracking View

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

// MARK: - Schedule Overview

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

// MARK: - Live Session Control

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

// MARK: - Session Components

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

// MARK: - Routine Checklist

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

// MARK: - Environment Section

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
