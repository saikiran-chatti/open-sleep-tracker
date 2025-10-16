//
//  SleepTrackingView.swift
//  open-sleep-tracker
//
//  Created by AI Assistant on 10/16/25.
//

import SwiftUI

struct SleepTrackingView: View {
    @ObservedObject var audioAgent: AudioClassificationAgent
    @State private var showingSessionDetails = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Text("Sleep Tracking")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Monitor your sleep in real-time")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 20)
                
                // Current Session Status
                GlassCardView {
                    VStack(spacing: 20) {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.blue)
                            Text("Current Session")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        if audioAgent.isRecording {
                            VStack(spacing: 15) {
                                // Recording indicator
                                HStack {
                                    Circle()
                                        .fill(.red)
                                        .frame(width: 12, height: 12)
                                        .scaleEffect(audioAgent.isRecording ? 1.2 : 1.0)
                                        .animation(.easeInOut(duration: 1.0).repeatForever(), value: audioAgent.isRecording)
                                    
                                    Text("Recording Active")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                }
                                
                                // Duration
                                Text(formatDuration(audioAgent.recordingDuration))
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                // Snore level indicator
                                VStack(spacing: 8) {
                                    Text("Current Snore Level")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    HStack {
                                        ForEach(0..<5, id: \.self) { index in
                                            Circle()
                                                .fill(index < Int(audioAgent.currentSnoreLevel * 5) ? .orange : .gray.opacity(0.3))
                                                .frame(width: 12, height: 12)
                                        }
                                    }
                                    
                                    Text("\(Int(audioAgent.currentSnoreLevel * 100))%")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Button("Stop Session") {
                                    audioAgent.stopRecording()
                                }
                                .buttonStyle(GlassButtonStyle(style: .destructive))
                            }
                        } else {
                            VStack(spacing: 15) {
                                Image(systemName: "moon.stars")
                                    .font(.system(size: 50))
                                    .foregroundColor(.blue.opacity(0.6))
                                
                                Text("Ready to track your sleep")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                Text("Start a session to begin monitoring your sleep patterns and snoring")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                
                                Button("Start Sleep Session") {
                                    audioAgent.startRecording()
                                }
                                .buttonStyle(GlassButtonStyle(style: .primary))
                            }
                        }
                    }
                }
                
                // Real-time Snore Detection
                if audioAgent.isRecording {
                    GlassCardView {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "waveform.path.ecg")
                                    .foregroundColor(.orange)
                                Text("Real-time Detection")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            VStack(spacing: 10) {
                                // Snore intensity meter
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Snore Intensity")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(.gray.opacity(0.2))
                                                .frame(height: 20)
                                            
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [.green, .yellow, .orange, .red],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                                .frame(width: geometry.size.width * audioAgent.currentSnoreLevel, height: 20)
                                        }
                                    }
                                    .frame(height: 20)
                                    
                                    HStack {
                                        Text("Light")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("Heavy")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                // Last snore event
                                if let lastEvent = audioAgent.lastSnoreEvent {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Last Snore Event")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                            
                                            Text("\(Int(lastEvent.intensity * 100))% intensity")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            
                                            Text("\(Int(lastEvent.confidence * 100))% confidence")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(formatTime(lastEvent.timestamp))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding()
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(.blue.opacity(0.1))
                                    )
                                }
                            }
                        }
                    }
                }
                
                // Session History
                GlassCardView {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.green)
                            Text("Recent Sessions")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                            
                            Button("View All") {
                                showingSessionDetails = true
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                        }
                        
                        // Placeholder for recent sessions
                        VStack(spacing: 10) {
                            ForEach(0..<3, id: \.self) { index in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Sleep Session")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        Text("8h 32m • 12 snore events")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .trailing, spacing: 4) {
                                        Text("85%")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.green)
                                        
                                        Text("Quality")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .padding(.vertical, 8)
                                
                                if index < 2 {
                                    Divider()
                                        .background(.white.opacity(0.2))
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .sheet(isPresented: $showingSessionDetails) {
            SessionDetailsView()
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        return String(format: "%d:%02d", hours, minutes)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct SessionDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    Text("Session Details")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                    // Placeholder content
                    ForEach(0..<10, id: \.self) { index in
                        GlassCardView {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Sleep Session \(index + 1)")
                                        .font(.headline)
                                    Text("8h 32m • 12 snore events")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text("85%")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SleepTrackingView(audioAgent: AudioClassificationAgent())
}