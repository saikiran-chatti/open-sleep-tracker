//
//  RecordingsView.swift
//  open-sleep-tracker
//
//  Redesigned by Codex on 10/21/25.
//

import SwiftUI

struct RecordingsView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @State private var searchText = ""
    @State private var selectedRecording: AudioRecording?
    @State private var recordingPendingDeletion: AudioRecording?
    @State private var showDeleteConfirmation = false
    
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
            ZStack {
                AppBackgroundView()
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 24) {
                        RecordingsHeader(summary: summary)
                        
                        if audioRecorder.isRecording {
                            LiveRecordingBanner(
                                duration: audioRecorder.recordingDuration,
                                level: audioRecorder.audioLevel,
                                stopAction: audioRecorder.stopRecording
                            )
                        }
                        
                        if recordings.isEmpty {
                            EmptyRecordingsState(startAction: startRecording)
                        } else {
                            VStack(alignment: .leading, spacing: 16) {
                                SectionHeader(
                                    title: "Saved Sessions",
                                    subtitle: "Powered by Audio Classification Agent"
                                )
                                
                                LazyVStack(spacing: 16) {
                                    ForEach(recordings) { recording in
                                        RecordingCard(
                                            recording: recording,
                                            isPlaying: audioRecorder.currentlyPlayingId == recording.id && audioRecorder.isPlaying,
                                            playAction: { audioRecorder.togglePlayback(recording) },
                                            showAction: { selectedRecording = recording },
                                            deleteAction: {
                                                recordingPendingDeletion = recording
                                                showDeleteConfirmation = true
                                            }
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Sound Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        startRecording()
                    } label: {
                        Label("Quick Record", systemImage: "plus.circle")
                    }
                }
            }
        }
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .automatic),
            prompt: "Search recordings"
        )
        .sheet(item: $selectedRecording) { recording in
            RecordingDetailView(recording: recording)
                .presentationDetents([.medium, .large])
        }
        .confirmationDialog(
            "Delete recording?",
            isPresented: $showDeleteConfirmation,
            presenting: recordingPendingDeletion
        ) { recording in
            Button("Delete", role: .destructive) {
                audioRecorder.deleteRecording(recording)
            }
        } message: { recording in
            Text("Remove \(recording.fileName)? This action cannot be undone.")
        }
    }
    
    private func startRecording() {
        if !audioRecorder.isRecording {
            audioRecorder.startRecording()
        }
    }
}

// MARK: - Header & Summary

private struct RecordingsHeader: View {
    let summary: RecordingSummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SectionHeader(
                title: "Captured Nights",
                subtitle: "Snore samples for personalization & model retraining"
            )
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                SummaryTile(
                    title: "Sessions",
                    value: "\(summary.count)",
                    caption: "Across \(summary.uniqueNights) nights",
                    icon: "dot.radiowaves.left.and.right",
                    tint: .accentBlue
                )
                
                SummaryTile(
                    title: "Listening Time",
                    value: summary.totalDuration,
                    caption: "Stored locally & encrypted",
                    icon: "clock.arrow.circlepath",
                    tint: .accentPurple
                )
                
                SummaryTile(
                    title: "Library Size",
                    value: summary.totalSize,
                    caption: "Auto pruned by Data Sync Agent",
                    icon: "externaldrive.fill.badge.timelapse",
                    tint: .accentTeal
                )
                
                SummaryTile(
                    title: "Avg. Snore Intensity",
                    value: summary.averageIntensity,
                    caption: "High = review with AI coach",
                    icon: "waveform",
                    tint: .accentOrange
                )
            }
        }
    }
}

private struct SummaryTile: View {
    @EnvironmentObject var themeManager: ThemeManager
    let title: String
    let value: String
    let caption: String
    let icon: String
    let tint: Color

    @State private var appeared = false

    var body: some View {
        let theme = themeManager.selectedTheme

        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(tint)

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(tint)
            }

            Spacer(minLength: 0)

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(theme.textPrimary)
                .contentTransition(.numericText())

            Text(caption)
                .font(.caption)
                .foregroundStyle(theme.textSecondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(theme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            LinearGradient(
                                colors: [tint.opacity(0.12), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    tint.opacity(0.3),
                                    tint.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: tint.opacity(0.15), radius: 8, x: 0, y: 4)
        .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
        .scaleEffect(appeared ? 1.0 : 0.95)
        .opacity(appeared ? 1.0 : 0.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: appeared)
        .animation(.easeInOut(duration: 0.3), value: theme)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.1)) {
                appeared = true
            }
        }
    }
}

private struct LiveRecordingBanner: View {
    let duration: TimeInterval
    let level: Float
    let stopAction: () -> Void
    @State private var pulse = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("Recording in progress", systemImage: "dot.radiowaves.left.and.right")
                    .font(.headline)
                    .foregroundStyle(Color.accentOrange)
                
                Spacer()
                
                Button("Stop") {
                    stopAction()
                }
                .font(.caption)
                .foregroundStyle(Color.accentOrange)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.white.opacity(0.08))
                .clipShape(Capsule())
            }
            
            Text("Audio Classification Agent is capturing clean samples and tagging snore intensity.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
            
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.accentOrange.opacity(0.25))
                        .frame(width: 56, height: 56)
                        .scaleEffect(pulse ? 1.1 : 0.85)
                        .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulse)
                    
                    Circle()
                        .fill(Color.accentOrange)
                        .frame(width: 18, height: 18)
                }
                .onAppear { pulse = true }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Elapsed \(duration.formattedDurationDescription)")
                        .font(.subheadline)
                        .foregroundStyle(.white)
                    
                    ProgressView(value: Double(level))
                        .tint(Color.accentOrange)
                        .background(Capsule().fill(.white.opacity(0.1)))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(22)
        .glassCard(
            cornerRadius: 26,
            tint: LinearGradient(
                colors: [Color.accentOrange.opacity(0.2), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

private struct RecordingCard: View {
    let recording: AudioRecording
    let isPlaying: Bool
    let playAction: () -> Void
    let showAction: () -> Void
    let deleteAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(recordingTitle)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text(recording.formattedDate)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }

                Spacer()

                // Encryption badge
                if recording.isEncrypted {
                    Image(systemName: "lock.shield.fill")
                        .font(.caption)
                        .foregroundStyle(.accentGreen)
                }

                Menu {
                    Button("Review details", action: showAction)
                    Button("Delete", role: .destructive, action: deleteAction)
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            HStack(spacing: 16) {
                MetricPill(
                    title: "Duration",
                    value: recording.formattedDuration,
                    icon: "clock.badge.checkmark",
                    tint: Color.accentBlue
                )

                MetricPill(
                    title: "Size",
                    value: recording.fileSize,
                    icon: "externaldrive.fill",
                    tint: Color.accentTeal
                )

                MetricPill(
                    title: "Intensity",
                    value: "\(Int(recording.audioLevel * 100))%",
                    icon: "waveform.path.ecg",
                    tint: recording.audioLevel > 0.6 ? Color.accentOrange : Color.accentGreen
                )
            }

            HStack(spacing: 12) {
                Button {
                    playAction()
                } label: {
                    Label(isPlaying ? "Stop" : "Play snippet", systemImage: isPlaying ? "stop.fill" : "play.fill")
                        .font(.subheadline)
                }
                .buttonStyle(.borderedProminent)
                .tint(isPlaying ? Color.accentOrange.opacity(0.8) : Color.accentBlue.opacity(0.8))

                Button("Open analysis", action: showAction)
                    .buttonStyle(.bordered)
                    .tint(Color.accentPurple)
            }

            HStack(spacing: 8) {
                if recording.audioLevel > 0.7 {
                    BadgeView(text: "High snore intensity", icon: "exclamationmark.triangle.fill", color: Color.accentOrange)
                } else if recording.audioLevel < 0.3 {
                    BadgeView(text: "Quiet sample", icon: "leaf", color: Color.accentGreen)
                }

                if recording.isEncrypted {
                    BadgeView(text: "Encrypted", icon: "lock.fill", color: Color.accentTeal)
                }
            }
        }
        .padding(22)
        .glassCard(
            cornerRadius: 24,
            tint: LinearGradient(
                colors: [.white.opacity(0.04), Color.accentBlue.opacity(0.12)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            shadowColor: .black.opacity(0.2)
        )
    }

    private var recordingTitle: String {
        recording.fileName.replacingOccurrences(of: ".m4a", with: "").replacingOccurrences(of: ".encrypted", with: "")
    }
}

private struct EmptyRecordingsState: View {
    let startAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "waveform.slash")
                .font(.system(size: 54))
                .foregroundStyle(Color.accentBlue)
            
            Text("No recordings yet")
                .font(.headline)
                .foregroundStyle(.white)
            
            Text("Start a sleep session and Audio Classification Agent will capture the first sample.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.65))
                .multilineTextAlignment(.center)
            
            Button(action: startAction) {
                Label("Start recording", systemImage: "record.circle")
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.accentGreen.opacity(0.9))
        }
        .padding(36)
        .glassCard(
            cornerRadius: 26,
            tint: LinearGradient(
                colors: [Color.accentBlue.opacity(0.18), .clear],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Detail Sheet

private struct RecordingDetailView: View {
    let recording: AudioRecording
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionHeader(
                    title: "Recording Overview",
                    subtitle: "Captured \(recording.formattedDate)"
                )
                
                VStack(alignment: .leading, spacing: 12) {
                    Label("File name: \(recording.fileName)", systemImage: "doc")
                    Label("Duration: \(recording.formattedDuration)", systemImage: "clock")
                    Label("File size: \(recording.fileSize)", systemImage: "externaldrive")
                    
                    if let end = recording.endTime {
                        Label("Completed: \(formatted(date: end))", systemImage: "checkmark.circle")
                    }
                }
                .padding(20)
                .glassCard(cornerRadius: 24)
                
                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader(title: "Agent Notes", subtitle: "Auto-generated tags")
                    
                    BadgeView(text: "Audio Classification Agent", icon: "waveform", color: Color.accentBlue)
                    BadgeView(text: "Sleep Pattern Analysis Agent", icon: "chart.xyaxis.line", color: Color.accentPurple)
                    BadgeView(text: "Health Integration Agent", icon: "heart", color: Color.accentTeal)
                }
                .padding(20)
                .glassCard(
                    cornerRadius: 24,
                    tint: LinearGradient(
                        colors: [Color.accentPurple.opacity(0.18), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            }
            .padding(20)
        }
        .background(AppBackgroundView())
        .presentationBackground(.ultraThinMaterial)
    }
    
    private func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
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
