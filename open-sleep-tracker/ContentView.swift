//
//  ContentView.swift
//  open-sleep-tracker
//
//  Created by Jay Chatti on 10/16/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isRecording = false
    @State private var snoreLevel: Double = 0.0
    @State private var recordingDuration: TimeInterval = 0
    @State private var timer: Timer?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 10) {
                    Text("Sleep Tracker")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Mock Data Mode - UI Development")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Recording Status
                VStack(spacing: 20) {
                    if isRecording {
                        VStack(spacing: 15) {
                            // Recording indicator
                            HStack {
                                Circle()
                                    .fill(.red)
                                    .frame(width: 12, height: 12)
                                    .scaleEffect(isRecording ? 1.2 : 1.0)
                                    .animation(.easeInOut(duration: 1.0).repeatForever(), value: isRecording)
                                
                                Text("Recording...")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text(formatDuration(recordingDuration))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            
                            // Duration
                            Text(formatDuration(recordingDuration))
                                .font(.title)
                                .fontWeight(.bold)
                            
                            // Snore level indicator
                            VStack(spacing: 8) {
                                Text("Current Snore Level")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                HStack {
                                    ForEach(0..<5, id: \.self) { index in
                                        Circle()
                                            .fill(index < Int(snoreLevel * 5) ? .orange : .gray.opacity(0.3))
                                            .frame(width: 12, height: 12)
                                    }
                                }
                                
                                Text("\(Int(snoreLevel * 100))%")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Button("Stop Recording") {
                                stopRecording()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                        }
                    } else {
                        VStack(spacing: 15) {
                            Image(systemName: "moon.stars")
                                .font(.system(size: 50))
                                .foregroundColor(.blue.opacity(0.6))
                            
                            Text("Ready to track your sleep")
                                .font(.headline)
                            
                            Text("Start a session to begin monitoring your sleep patterns and snoring")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button("Start Sleep Session") {
                                startRecording()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.ultraThinMaterial)
                )
                
                // Mock Data Stats
                VStack(alignment: .leading, spacing: 15) {
                    Text("Mock Data Statistics")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                        StatCard(title: "Sleep Quality", value: "85%", color: .green, icon: "moon.stars.fill")
                        StatCard(title: "Snore Events", value: "\(Int.random(in: 5...25))", color: .orange, icon: "waveform.path.ecg")
                        StatCard(title: "Heart Rate", value: "\(Int.random(in: 60...80)) BPM", color: .red, icon: "heart.fill")
                        StatCard(title: "Duration", value: "8h 32m", color: .blue, icon: "clock.fill")
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(.ultraThinMaterial)
                )
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
    }
    
    private func startRecording() {
        isRecording = true
        recordingDuration = 0
        startTimer()
        startMockDataGeneration()
    }
    
    private func stopRecording() {
        isRecording = false
        stopTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            recordingDuration += 0.1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        recordingDuration = 0
    }
    
    private func startMockDataGeneration() {
        // Generate random snore levels for demonstration
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            if !isRecording {
                timer.invalidate()
                return
            }
            
            let randomValue = Double.random(in: 0...1)
            if randomValue > 0.7 { // 30% chance of snore event
                snoreLevel = Double.random(in: 0.3...1.0)
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        return String(format: "%d:%02d", hours, minutes)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    ContentView()
}