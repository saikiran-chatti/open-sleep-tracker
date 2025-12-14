//
//  RecordingsView.swift
//  open-sleep-tracker
//
//  Apple-style minimalist recordings
//

import SwiftUI

struct RecordingsView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @State private var searchText = ""
    @State private var selectedRecording: AudioRecording?
    @State private var recordingPendingDeletion: AudioRecording?
    @State private var showDeleteConfirmation = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var recordings: [AudioRecording] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return audioRecorder.recordings
        }
        return audioRecorder.recordings.filter { recording in
            let needle = searchText.lowercased()
            return recording.fileName.lowercased().contains(needle) ||
            recording.formattedDate.lowercased().contains(needle)
        }
    }

    private var summary: RecordingSummary {
        RecordingSummary(recordings: audioRecorder.recordings)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // Summary Stats
                    SummaryStatsView(summary: summary)

                    // Live Recording Banner
                    if audioRecorder.isRecording {
                        LiveRecordingCard(
                            duration: audioRecorder.recordingDuration,
                            level: audioRecorder.audioLevel,
                            stopAction: audioRecorder.stopRecording
                        )
                    }

                    // Recordings List
                    if recordings.isEmpty {
                        EmptyStateView(
                            icon: "waveform.slash",
                            title: "No Recordings",
                            message: "Start a sleep session to capture audio",
                            action: ("Start Recording", {
                                if !audioRecorder.isRecording {
                                    audioRecorder.startRecording()
                                }
                            })
                        )
                    } else {
                        RecordingsListView(
                            recordings: recordings,
                            audioRecorder: audioRecorder,
                            onSelect: { selectedRecording = $0 },
                            onDelete: {
                                recordingPendingDeletion = $0
                                showDeleteConfirmation = true
                            }
                        )
                    }
                }
                .padding()
            }
            .background(Color.appBackground)
            .navigationTitle("Recordings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if !audioRecorder.isRecording {
                            audioRecorder.startRecording()
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
        }
        .searchable(text: $searchText, prompt: "Search recordings")
        .sheet(item: $selectedRecording) { recording in
            RecordingDetailSheet(recording: recording)
                .presentationDetents([.medium, .large])
        }
        .confirmationDialog(
            "Delete Recording",
            isPresented: $showDeleteConfirmation,
            presenting: recordingPendingDeletion
        ) { recording in
            Button("Delete", role: .destructive) {
                audioRecorder.deleteRecording(recording)
            }
        } message: { recording in
            Text("This will permanently delete \"\(recording.fileName)\"")
        }
    }
}

// MARK: - Summary Stats

struct SummaryStatsView: View {
    let summary: RecordingSummary

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            StatCard(title: "Sessions", value: "\(summary.count)", icon: "waveform", color: .blue)
            StatCard(title: "Duration", value: summary.totalDuration, icon: "clock", color: .purple)
            StatCard(title: "Storage", value: summary.totalSize, icon: "internaldrive", color: .teal)
            StatCard(title: "Avg Level", value: summary.averageIntensity, icon: "chart.bar", color: .orange)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)

            Text(value)
                .font(.title3)
                .fontWeight(.semibold)

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.appSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Live Recording Card

struct LiveRecordingCard: View {
    let duration: TimeInterval
    let level: Float
    let stopAction: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                HStack(spacing: 8) {
                    Circle()
                        .fill(.orange)
                        .frame(width: 10, height: 10)

                    Text("Recording in Progress")
                        .font(.headline)
                }

                Spacer()

                Button("Stop") {
                    stopAction()
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.orange)
            }

            HStack {
                VStack(alignment: .leading) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(duration.formattedDurationDescription)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Level")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(Int(level * 100))%")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }

            // Progress bar
            GeometryReader { geometry in
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.appSeparator.opacity(0.3))
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.orange)
                            .frame(width: geometry.size.width * CGFloat(level))
                    }
            }
            .frame(height: 6)
        }
        .padding(16)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Recordings List

struct RecordingsListView: View {
    let recordings: [AudioRecording]
    @ObservedObject var audioRecorder: AudioRecorder
    let onSelect: (AudioRecording) -> Void
    let onDelete: (AudioRecording) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("All Recordings")
                .font(.headline)
                .padding(.horizontal, 4)

            VStack(spacing: 8) {
                ForEach(recordings) { recording in
                    RecordingRow(
                        recording: recording,
                        isPlaying: audioRecorder.currentlyPlayingId == recording.id && audioRecorder.isPlaying,
                        onPlay: { audioRecorder.togglePlayback(recording) },
                        onSelect: { onSelect(recording) },
                        onDelete: { onDelete(recording) }
                    )
                }
            }
        }
    }
}

struct RecordingRow: View {
    let recording: AudioRecording
    let isPlaying: Bool
    let onPlay: () -> Void
    let onSelect: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            // Play Button
            Button {
                onPlay()
            } label: {
                Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                    .font(.title3)
                    .foregroundStyle(isPlaying ? .orange : .blue)
                    .frame(width: 44, height: 44)
                    .background(isPlaying ? Color.orange.opacity(0.12) : Color.blue.opacity(0.12))
                    .clipShape(Circle())
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(recording.fileName.replacingOccurrences(of: ".m4a", with: ""))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(recording.formattedDate)
                    Text("•")
                    Text(recording.formattedDuration)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            // Menu
            Menu {
                Button("Details", action: onSelect)
                Button("Delete", role: .destructive, action: onDelete)
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(Color.appSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var action: (String, () -> Void)?

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text(title)
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let action = action {
                Button(action.0) {
                    action.1()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(Color.appSecondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - Recording Detail Sheet

struct RecordingDetailSheet: View {
    let recording: AudioRecording

    var body: some View {
        NavigationStack {
            List {
                Section("Details") {
                    LabeledContent("File Name", value: recording.fileName)
                    LabeledContent("Date", value: recording.formattedDate)
                    LabeledContent("Duration", value: recording.formattedDuration)
                    LabeledContent("Size", value: recording.fileSize)
                }

                Section("Audio Analysis") {
                    LabeledContent("Average Level", value: "\(Int(recording.audioLevel * 100))%")

                    if recording.audioLevel > 0.7 {
                        Label("High snore activity detected", systemImage: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    } else if recording.audioLevel < 0.3 {
                        Label("Quiet recording", systemImage: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }

                if recording.isEncrypted {
                    Section {
                        Label("This recording is encrypted", systemImage: "lock.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
            .navigationTitle("Recording")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Summary Model

private struct RecordingSummary {
    let count: Int
    let uniqueNights: Int
    let totalDuration: String
    let totalSize: String
    let averageIntensity: String

    init(recordings: [AudioRecording]) {
        count = recordings.count

        let nights = Set(recordings.map { Calendar.current.startOfDay(for: $0.startTime) })
        uniqueNights = nights.count

        let totalSeconds = recordings.reduce(0.0) { $0 + $1.duration }
        totalDuration = totalSeconds.formattedDurationDescription

        let totalBytes = recordings.reduce(Int64(0)) { partial, recording in
            let attributes = try? FileManager.default.attributesOfItem(atPath: recording.fileURL.path)
            let size = attributes?[.size] as? Int64 ?? 0
            return partial + size
        }
        totalSize = ByteCountFormatter.string(fromByteCount: totalBytes, countStyle: .file)

        if recordings.isEmpty {
            averageIntensity = "—"
        } else {
            let average = recordings.reduce(0.0) { $0 + Double($1.audioLevel) } / Double(recordings.count)
            averageIntensity = "\(Int(average * 100))%"
        }
    }
}

// MARK: - Legacy Support

private struct RecordingsHeader: View {
    let summary: RecordingSummary

    var body: some View {
        SummaryStatsView(summary: summary)
    }
}

private struct SummaryTile: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let value: String
    let caption: String
    let icon: String
    let tint: Color

    var body: some View {
        StatCard(title: title, value: value, icon: icon, color: tint)
    }
}

private struct LiveRecordingBanner: View {
    let duration: TimeInterval
    let level: Float
    let stopAction: () -> Void

    var body: some View {
        LiveRecordingCard(duration: duration, level: level, stopAction: stopAction)
    }
}

private struct RecordingCard: View {
    let recording: AudioRecording
    let isPlaying: Bool
    let playAction: () -> Void
    let showAction: () -> Void
    let deleteAction: () -> Void

    var body: some View {
        RecordingRow(
            recording: recording,
            isPlaying: isPlaying,
            onPlay: playAction,
            onSelect: showAction,
            onDelete: deleteAction
        )
    }
}

private struct EmptyRecordingsState: View {
    let startAction: () -> Void

    var body: some View {
        EmptyStateView(
            icon: "waveform.slash",
            title: "No Recordings",
            message: "Start a sleep session to capture audio",
            action: ("Start Recording", startAction)
        )
    }
}

private struct RecordingDetailView: View {
    let recording: AudioRecording

    var body: some View {
        RecordingDetailSheet(recording: recording)
    }
}
