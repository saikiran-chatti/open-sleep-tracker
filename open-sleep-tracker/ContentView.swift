//
//  ContentView.swift
//  open-sleep-tracker
//
//  Redesigned by Codex on 10/21/25.
//  Refactored by AI Agent on 11/22/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var audioRecorder = AudioRecorder()
    @StateObject private var themeManager = ThemeManager()
    @State private var selectedTab: Tab = .dashboard
    @State private var showOnboarding = false

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardScreen(selectedTab: $selectedTab, audioRecorder: audioRecorder)
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
        .environmentObject(themeManager)
        .sheet(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
                .environmentObject(themeManager)
        }
        .onAppear {
            // Check if first launch
            if !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
                showOnboarding = true
            }
        }
    }

    enum Tab {
        case dashboard, sessions, recordings, analytics, settings
    }
}

// MARK: - Onboarding View

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to Sleep Intelligence",
            subtitle: "Your AI-powered sleep companion",
            description: "Track, analyze, and improve your sleep with 6 specialized AI agents working together.",
            icon: "moon.stars.fill",
            color: .accentPurple
        ),
        OnboardingPage(
            title: "Smart Audio Detection",
            subtitle: "Powered by Audio Classification Agent",
            description: "Advanced machine learning detects snoring patterns, filters noise, and provides real-time insights.",
            icon: "waveform.circle.fill",
            color: .accentGreen
        ),
        OnboardingPage(
            title: "Health Integration",
            subtitle: "Connected to Apple Health",
            description: "Sync with Apple Watch for heart rate, sleep stages, and comprehensive health analytics.",
            icon: "heart.text.square",
            color: .accentTeal
        ),
        OnboardingPage(
            title: "Privacy First",
            subtitle: "Your data stays yours",
            description: "All AI processing happens on-device. Your sleep data is encrypted and never shared.",
            icon: "lock.shield.fill",
            color: .accentBlue
        )
    ]

    var body: some View {
        ZStack {
            AppBackgroundView()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 32)

                // Buttons
                VStack(spacing: 16) {
                    if currentPage < pages.count - 1 {
                        Button {
                            withAnimation {
                                currentPage += 1
                            }
                        } label: {
                            Text("Continue")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [.accentBlue, .accentPurple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        Button("Skip") {
                            completeOnboarding()
                        }
                        .foregroundStyle(.white.opacity(0.7))
                    } else {
                        Button {
                            completeOnboarding()
                        } label: {
                            Text("Get Started")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        colors: [.accentGreen, .accentTeal],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .interactiveDismissDisabled()
    }

    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        isPresented = false
    }
}

struct OnboardingPage {
    let title: String
    let subtitle: String
    let description: String
    let icon: String
    let color: Color
}

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 80))
                .foregroundStyle(page.color)
                .padding(40)
                .background(
                    Circle()
                        .fill(page.color.opacity(0.2))
                        .overlay(
                            Circle()
                                .stroke(page.color.opacity(0.3), lineWidth: 2)
                        )
                )
                .shadow(color: page.color.opacity(0.4), radius: 30, y: 10)

            // Text Content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(page.color)

                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    ContentView()
}
