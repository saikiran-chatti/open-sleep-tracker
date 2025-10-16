//
//  MainDashboardView.swift
//  open-sleep-tracker
//
//  Created by AI Assistant on 10/16/25.
//

import SwiftUI

struct MainDashboardView: View {
    @StateObject private var audioAgent = AudioClassificationAgent()
    @StateObject private var healthAgent = HealthIntegrationAgent()
    @StateObject private var analysisAgent = SleepPatternAnalysisAgent()
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.1),
                    Color.indigo.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            TabView(selection: $selectedTab) {
                // Dashboard Tab
                DashboardTabView(
                    audioAgent: audioAgent,
                    healthAgent: healthAgent,
                    analysisAgent: analysisAgent
                )
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(0)
                
                // Sleep Tracking Tab
                SleepTrackingView(audioAgent: audioAgent)
                .tabItem {
                    Image(systemName: "moon.fill")
                    Text("Sleep")
                }
                .tag(1)
                
                // Analytics Tab
                AnalyticsView(analysisAgent: analysisAgent)
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Analytics")
                }
                .tag(2)
                
                // Settings Tab
                SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(3)
            }
            .accentColor(.white)
        }
        .onAppear {
            healthAgent.requestHealthKitPermissions()
            analysisAgent.analyzeSleepPatterns()
        }
    }
}

struct DashboardTabView: View {
    @ObservedObject var audioAgent: AudioClassificationAgent
    @ObservedObject var healthAgent: HealthIntegrationAgent
    @ObservedObject var analysisAgent: SleepPatternAnalysisAgent
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Text("Sleep Tracker")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Track your sleep patterns and snoring")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 20)
                
                // Quick Stats
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                    GlassCardView {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "moon.stars.fill")
                                    .foregroundColor(.blue)
                                Text("Sleep Quality")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Text("85%")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    GlassCardView {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "waveform.path.ecg")
                                    .foregroundColor(.orange)
                                Text("Snore Events")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Text("\(Int(audioAgent.currentSnoreLevel * 100))")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    GlassCardView {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                Text("Heart Rate")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Text("72 BPM")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                    }
                    
                    GlassCardView {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "lungs.fill")
                                    .foregroundColor(.green)
                                Text("Respiratory")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Text("16/min")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                // Sleep Session Control
                GlassCardView {
                    VStack(spacing: 20) {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.blue)
                            Text("Sleep Session")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        if audioAgent.isRecording {
                            VStack(spacing: 15) {
                                HStack {
                                    Circle()
                                        .fill(.red)
                                        .frame(width: 12, height: 12)
                                        .scaleEffect(audioAgent.isRecording ? 1.2 : 1.0)
                                        .animation(.easeInOut(duration: 1.0).repeatForever(), value: audioAgent.isRecording)
                                    
                                    Text("Recording...")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    Spacer()
                                    
                                    Text(formatDuration(audioAgent.recordingDuration))
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                }
                                
                                Button("Stop Session") {
                                    audioAgent.stopRecording()
                                }
                                .buttonStyle(GlassButtonStyle(style: .destructive))
                            }
                        } else {
                            Button("Start Sleep Session") {
                                audioAgent.startRecording()
                            }
                            .buttonStyle(GlassButtonStyle(style: .primary))
                        }
                    }
                }
                
                // Recent Insights
                if let insights = analysisAgent.sleepInsights {
                    GlassCardView {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("Insights")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(insights.recommendations.prefix(3), id: \.self) { recommendation in
                                    HStack(alignment: .top, spacing: 10) {
                                        Circle()
                                            .fill(.blue)
                                            .frame(width: 6, height: 6)
                                            .padding(.top, 6)
                                        
                                        Text(recommendation)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        return String(format: "%d:%02d", hours, minutes)
    }
}

#Preview {
    MainDashboardView()
}