//
//  ContentView.swift
//  open-sleep-tracker
//
//  Created by Jay Chatti on 10/16/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var audioRecorder = AudioRecorder()
    @State private var selectedTab = 0
    @State private var pulseAnimation = false
    @State private var glowAnimation = false
    @State private var backgroundOffset: CGFloat = 0
    @Namespace private var glassNamespace
    
    var body: some View {
        ZStack {
            // Dynamic Background with Glass Morphism
            backgroundGradient
                .ignoresSafeArea()
            
            // Main Content
            TabView(selection: $selectedTab) {
                // Dashboard Tab
                DashboardView(
                    audioRecorder: audioRecorder,
                    pulseAnimation: $pulseAnimation,
                    glowAnimation: $glowAnimation,
                    glassNamespace: glassNamespace
                )
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Dashboard")
                }
                .tag(0)
                
                // Sleep Tracking Tab
                SleepTrackingView(
                    audioRecorder: audioRecorder,
                    pulseAnimation: $pulseAnimation,
                    glassNamespace: glassNamespace
                )
                .tabItem {
                    Image(systemName: "moon.stars.fill")
                    Text("Sleep")
                }
                .tag(1)
                
                // Recordings Tab
                RecordingsView(audioRecorder: audioRecorder, glassNamespace: glassNamespace)
                .tabItem {
                    Image(systemName: "waveform")
                    Text("Recordings")
                }
                .tag(2)
                
                // Analytics Tab
                AnalyticsView(glassNamespace: glassNamespace)
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Analytics")
                }
                .tag(3)
                
                // Settings Tab
                SettingsView(glassNamespace: glassNamespace)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(4)
            }
            .accentColor(.white)
            .preferredColorScheme(.dark)
        }
        .onAppear {
            startBackgroundAnimations()
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
            
            // Animated overlay
            RadialGradient(
                colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.05),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 50,
                endRadius: 400
            )
            .scaleEffect(glowAnimation ? 1.2 : 1.0)
            .opacity(glowAnimation ? 0.8 : 0.4)
            .animation(.easeInOut(duration: 3).repeatForever(autoreverses: true), value: glowAnimation)
            
            // Floating particles effect
            ForEach(0..<20, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.white.opacity(0.1), .blue.opacity(0.05)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat.random(in: 2...8))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .offset(y: backgroundOffset)
                    .animation(
                        .linear(duration: Double.random(in: 10...20))
                        .repeatForever(autoreverses: false),
                        value: backgroundOffset
                    )
            }
        }
    }
    
    private func startBackgroundAnimations() {
        withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
            glowAnimation = true
        }
        
        withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
            backgroundOffset = -UIScreen.main.bounds.height
        }
    }
    
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        return String(format: "%d:%02d", hours, minutes)
    }
}

// MARK: - Dashboard View
struct DashboardView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @Binding var pulseAnimation: Bool
    @Binding var glowAnimation: Bool
    let glassNamespace: Namespace.ID
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                // Header with Glass Effect
                headerSection
                
                // Quick Stats Grid
                statsGrid
                
                // Sleep Session Control
                sleepSessionCard
                
                // Recent Insights
                insightsCard
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 100)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Sleep Tracker")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text("Advanced Sleep Monitoring")
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
    
    private var statsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            StatCard(
                title: "Sleep Quality",
                value: "85%",
                icon: "moon.stars.fill",
                color: .green,
                glassNamespace: glassNamespace
            )
            
            StatCard(
                title: "Snore Events",
                value: "\(Int.random(in: 5...25))",
                icon: "waveform.path.ecg",
                color: .orange,
                glassNamespace: glassNamespace
            )
            
            StatCard(
                title: "Heart Rate",
                value: "\(Int.random(in: 60...80)) BPM",
                icon: "heart.fill",
                color: .red,
                glassNamespace: glassNamespace
            )
            
            StatCard(
                title: "Duration",
                value: "8h 32m",
                icon: "clock.fill",
                color: .blue,
                glassNamespace: glassNamespace
            )
        }
    }
    
    private var sleepSessionCard: some View {
        VStack(spacing: 20) {
            HStack {
                Image(systemName: "moon.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                Text("Sleep Session")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            if audioRecorder.isRecording {
                recordingActiveView
            } else {
                recordingInactiveView
            }
        }
        .padding(24)
        .background(
            GlassCard(
                radius: 20,
                strokeWidth: 1,
                shadowRadius: 15
            )
        )
    }
    
    private var recordingActiveView: some View {
        VStack(spacing: 20) {
            // Recording indicator with pulse animation
            HStack {
                Circle()
                    .fill(.red)
                    .frame(width: 12, height: 12)
                    .scaleEffect(pulseAnimation ? 1.5 : 1.0)
                    .opacity(pulseAnimation ? 0.6 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseAnimation)
                
                Text("Recording Active")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text(formatDuration(audioRecorder.recordingDuration))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            
            // Duration display
            Text(formatDuration(audioRecorder.recordingDuration))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            // Snore level indicator
            VStack(spacing: 12) {
                Text("Current Snore Level")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .textCase(.uppercase)
                    .tracking(1)
                
                HStack(spacing: 8) {
                    ForEach(0..<5, id: \.self) { index in
                        Circle()
                            .fill(index < Int(audioRecorder.audioLevel * 5) ? .orange : .white.opacity(0.2))
                            .frame(width: 16, height: 16)
                            .scaleEffect(index < Int(audioRecorder.audioLevel * 5) ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: audioRecorder.audioLevel)
                    }
                }
                
                Text("\(Int(audioRecorder.audioLevel * 100))%")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Button("Stop Session") {
                audioRecorder.stopRecording()
                pulseAnimation = false
            }
            .buttonStyle(GlassButtonStyle(style: .destructive))
        }
    }
    
    private var recordingInactiveView: some View {
        VStack(spacing: 20) {
            Image(systemName: "moon.stars")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue.opacity(0.8), .purple.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(glowAnimation ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: glowAnimation)
            
            Text("Ready to track your sleep")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            Text("Start a session to begin monitoring your sleep patterns and snoring with advanced AI analysis")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(3)
            
            Button("Start Sleep Session") {
                audioRecorder.startRecording()
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    pulseAnimation = true
                }
            }
            .buttonStyle(GlassButtonStyle(style: .primary))
        }
    }
    
    private var insightsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                Text("Sleep Insights")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("View All") {
                    // Show detailed insights
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                InsightRow(
                    icon: "moon.fill",
                    title: "Sleep Quality Improved",
                    description: "Your sleep quality has improved by 15% this week",
                    color: .green
                )
                
                InsightRow(
                    icon: "waveform.path.ecg",
                    title: "Snoring Reduced",
                    description: "Snoring events decreased by 8% compared to last week",
                    color: .orange
                )
                
                InsightRow(
                    icon: "heart.fill",
                    title: "Heart Rate Stable",
                    description: "Your heart rate patterns show good consistency",
                    color: .red
                )
            }
        }
        .padding(20)
        .background(
            GlassCard(
                radius: 16,
                strokeWidth: 1,
                shadowRadius: 10
            )
        )
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        return String(format: "%d:%02d", hours, minutes)
    }
}

// MARK: - Glass Card Component
struct GlassCard: View {
    let radius: CGFloat
    let strokeWidth: CGFloat
    let shadowRadius: CGFloat
    
    var body: some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.2), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: strokeWidth
                    )
            )
            .shadow(color: .blue.opacity(0.2), radius: shadowRadius, x: 0, y: 8)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let glassNamespace: Namespace.ID
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [color.opacity(0.3), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: color.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Insight Row
struct InsightRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .lineLimit(2)
            }
            
            Spacer()
        }
    }
}

// MARK: - Glass Button Style
struct GlassButtonStyle: ButtonStyle {
    enum Style {
        case primary, destructive, secondary
    }
    
    let style: Style
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 32)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(buttonGradient)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                LinearGradient(
                                    colors: [.white.opacity(0.3), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .shadow(color: shadowColor, radius: 15, x: 0, y: 8)
    }
    
    private var buttonGradient: LinearGradient {
        switch style {
        case .primary:
            return LinearGradient(
                colors: [.blue.opacity(0.8), .purple.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .destructive:
            return LinearGradient(
                colors: [.red.opacity(0.8), .pink.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .secondary:
            return LinearGradient(
                colors: [.white.opacity(0.1), .white.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case .primary:
            return .blue.opacity(0.3)
        case .destructive:
            return .red.opacity(0.3)
        case .secondary:
            return .white.opacity(0.1)
        }
    }
}

// MARK: - Sleep Tracking View
struct SleepTrackingView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @Binding var pulseAnimation: Bool
    let glassNamespace: Namespace.ID
    
    var body: some View {
        VStack {
            Text("Sleep Tracking")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
        }
    }
}

struct AnalyticsView: View {
    let glassNamespace: Namespace.ID
    
    var body: some View {
        VStack {
            Text("Analytics")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
        }
    }
}

struct SettingsView: View {
    let glassNamespace: Namespace.ID
    
    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
        }
    }
}

#Preview {
    ContentView()
}