//
//  RecordingsView.swift
//  open-sleep-tracker
//
//  Created by Jay Chatti on 10/16/25.
//

import SwiftUI

struct RecordingsView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    let glassNamespace: Namespace.ID
    @State private var selectedRecording: AudioRecording?
    @State private var showingDeleteAlert = false
    @State private var recordingToDelete: AudioRecording?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Header
                        headerSection
                        
                        // Current Recording (if recording)
                        if audioRecorder.isRecording {
                            currentRecordingCard
                        }
                        
                        // Recordings List
                        if audioRecorder.recordings.isEmpty && !audioRecorder.isRecording {
                            emptyStateView
                        } else {
                            recordingsList
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
        }
        .alert("Delete Recording", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let recording = recordingToDelete {
                    audioRecorder.deleteRecording(recording)
                }
            }
        } message: {
            Text("Are you sure you want to delete this recording? This action cannot be undone.")
        }
    }
    
    private var backgroundGradient: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.05, blue: 0.2),
                    Color(red: 0.15, green: 0.1, blue: 0.25)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Audio Recordings")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Manage your sleep recordings")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 30)
        .background(
            GlassCard(
                radius: 24,
                strokeWidth: 1,
                shadowRadius: 20
            )
        )
    }
    
    private var currentRecordingCard: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "mic.fill")
                    .font(.title2)
                    .foregroundColor(.red)
                
                Text("Currently Recording")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                Text(audioRecorder.currentRecording?.formattedDuration ?? "00:00")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .red.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                // Audio level indicator
                HStack(spacing: 4) {
                    ForEach(0..<10, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(index < Int(audioRecorder.audioLevel * 10) ? .red : .white.opacity(0.2))
                            .frame(width: 4, height: CGFloat(8 + index * 2))
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: audioRecorder.audioLevel)
                    }
                }
                
                Text("Audio Level: \(Int(audioRecorder.audioLevel * 100))%")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(20)
        .background(
            GlassCard(
                radius: 16,
                strokeWidth: 1,
                shadowRadius: 15
            )
        )
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "waveform.slash")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue.opacity(0.8), .purple.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            Text("No Recordings Yet")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Start a sleep session to begin recording your sleep patterns and snoring")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .padding(40)
        .background(
            GlassCard(
                radius: 20,
                strokeWidth: 1,
                shadowRadius: 15
            )
        )
    }
    
    private var recordingsList: some View {
        LazyVStack(spacing: 12) {
            ForEach(audioRecorder.recordings) { recording in
                RecordingCard(
                    recording: recording,
                    onPlay: { audioRecorder.playRecording(recording) },
                    onDelete: {
                        recordingToDelete = recording
                        showingDeleteAlert = true
                    }
                )
            }
        }
    }
}

// MARK: - Recording Card
struct RecordingCard: View {
    let recording: AudioRecording
    let onPlay: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Play button
            Button(action: onPlay) {
                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            
            // Recording info
            VStack(alignment: .leading, spacing: 4) {
                Text(recording.formattedDate)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack {
                    Text(recording.formattedDuration)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("•")
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text(recording.fileSize)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Spacer()
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.title3)
                    .foregroundColor(.red.opacity(0.8))
            }
        }
        .padding(16)
        .background(
            GlassCard(
                radius: 12,
                strokeWidth: 1,
                shadowRadius: 8
            )
        )
    }
}

#Preview {
    RecordingsView(
        audioRecorder: AudioRecorder(),
        glassNamespace: Namespace().wrappedValue
    )
}