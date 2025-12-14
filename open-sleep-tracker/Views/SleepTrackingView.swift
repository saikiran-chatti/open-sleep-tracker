//
//  SleepTrackingView.swift
//  open-sleep-tracker
//
//  Apple-style minimalist sleep tracking
//

import SwiftUI

// MARK: - Sleep Tracking View

struct SleepTrackingView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @State private var schedule = DashboardData.SessionSchedule.sample
    @State private var showStandBy = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Recording Control
                    RecordingControlCard(
                        audioRecorder: audioRecorder,
                        onStandBy: DeviceInfo.isIPad ? { showStandBy = true } : nil
                    )

                    // Schedule Overview
                    ScheduleCard(schedule: schedule)

                    // Pre-Sleep Checklist
                    ChecklistCard(routines: schedule.routines)

                    // Environment
                    EnvironmentCard(readings: schedule.environmentReadings)
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Sleep")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if DeviceInfo.isIPad && audioRecorder.isRecording {
                        Button {
                            showStandBy = true
                        } label: {
                            Label("StandBy", systemImage: "display")
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showStandBy) {
                if DeviceInfo.isIPad {
                    StandByView(audioRecorder: audioRecorder)
                }
            }
        }
    }
}

// MARK: - Recording Control Card

struct RecordingControlCard: View {
    @ObservedObject var audioRecorder: AudioRecorder
    var onStandBy: (() -> Void)?

    var body: some View {
        VStack(spacing: 20) {
            // Main Recording Button
            Button {
                if audioRecorder.isRecording {
                    audioRecorder.stopRecording()
                } else {
                    audioRecorder.startRecording()
                }
            } label: {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(audioRecorder.isRecording ? Color.orange.opacity(0.15) : Color.green.opacity(0.15))
                            .frame(width: 120, height: 120)

                        Image(systemName: audioRecorder.isRecording ? "stop.fill" : "moon.zzz.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(audioRecorder.isRecording ? .orange : .green)
                    }

                    Text(audioRecorder.isRecording ? "Stop Recording" : "Start Sleep Session")
                        .font(.headline)
                }
            }
            .buttonStyle(.plain)

            if audioRecorder.isRecording {
                // Recording Status
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Duration")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(audioRecorder.recordingDuration.formattedDurationDescription)
                                .font(.title3)
                                .fontWeight(.semibold)
                        }

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text("Status")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(.orange)
                                    .frame(width: 8, height: 8)
                                Text("Recording")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                        }
                    }

                    // Audio Level
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Audio Level")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        GeometryReader { geometry in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.appSeparator.opacity(0.3))
                                .overlay(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.orange)
                                        .frame(width: geometry.size.width * CGFloat(audioRecorder.audioLevel))
                                }
                        }
                        .frame(height: 8)
                    }

                    // StandBy Button (iPad)
                    if let standByAction = onStandBy {
                        Button {
                            standByAction()
                        } label: {
                            Label("Enter StandBy Mode", systemImage: "display")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(16)
                .background(Color.appTertiaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else {
                Text("Tap to start tracking your sleep")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(Color.appSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Schedule Card

struct ScheduleCard: View {
    let schedule: DashboardData.SessionSchedule

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Tonight's Schedule")
                    .font(.headline)

                Spacer()

                Text(schedule.sleepWindow)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Divider()

            ForEach(schedule.checkpoints) { checkpoint in
                HStack(spacing: 14) {
                    Image(systemName: checkpoint.icon)
                        .foregroundStyle(checkpoint.tint)
                        .frame(width: 32, height: 32)
                        .background(checkpoint.tint.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(checkpoint.timeLabel)
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Text(checkpoint.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text(checkpoint.phase)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(Color.appSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Checklist Card

struct ChecklistCard: View {
    let routines: [DashboardData.SessionSchedule.Routine]
    @State private var completed: Set<UUID> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Pre-Sleep Routine")
                    .font(.headline)

                Spacer()

                Text("\(completed.count)/\(routines.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            ForEach(routines) { routine in
                Button {
                    toggleCompletion(routine.id)
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: completed.contains(routine.id) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(completed.contains(routine.id) ? .green : .secondary)
                            .font(.title3)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(routine.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(completed.contains(routine.id) ? .secondary : .primary)

                            Text(routine.detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Color.appSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func toggleCompletion(_ id: UUID) {
        withAnimation {
            if completed.contains(id) {
                completed.remove(id)
            } else {
                completed.insert(id)
            }
        }
    }
}

// MARK: - Environment Card

struct EnvironmentCard: View {
    let readings: [DashboardData.SessionSchedule.EnvironmentReading]

    private var columns: [GridItem] {
        [GridItem(.flexible()), GridItem(.flexible())]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Environment")
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(readings) { reading in
                    EnvironmentTile(reading: reading)
                }
            }
        }
    }
}

struct EnvironmentTile: View {
    let reading: DashboardData.SessionSchedule.EnvironmentReading

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: reading.icon)
                    .foregroundStyle(reading.tint)

                Spacer()

                Text(reading.status)
                    .font(.caption)
                    .foregroundStyle(reading.tint)
            }

            Text(reading.value)
                .font(.title2)
                .fontWeight(.semibold)

            Text(reading.title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(14)
        .background(Color.appSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Legacy Support

struct ScheduleOverview: View {
    let schedule: DashboardData.SessionSchedule

    var body: some View {
        ScheduleCard(schedule: schedule)
    }
}

struct RoutineChecklist: View {
    let actions: [DashboardData.SessionSchedule.Routine]

    var body: some View {
        ChecklistCard(routines: actions)
    }
}

struct EnvironmentSection: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let readings: [DashboardData.SessionSchedule.EnvironmentReading]

    var body: some View {
        EnvironmentCard(readings: readings)
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
                title: "Activity",
                value: "\(Int(level * 100))%",
                icon: "waveform",
                tint: .orange
            )
        }
    }
}

struct SessionScheduler: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Session will start when you tap the button above")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
