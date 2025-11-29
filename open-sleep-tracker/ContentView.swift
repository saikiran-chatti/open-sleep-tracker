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
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if DeviceInfo.isIPad && horizontalSizeClass == .regular {
                // iPad with regular width: Use sidebar navigation
                iPadSidebarLayout
            } else {
                // iPhone or iPad compact: Use tab bar navigation
                iPhoneTabLayout
            }
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

    // MARK: - iPad Sidebar Layout

    private var iPadSidebarLayout: some View {
        NavigationSplitView {
            List(selection: $selectedTab) {
                ForEach(Tab.allCases) { tab in
                    NavigationLink(value: tab) {
                        Label(tab.title, systemImage: tab.icon)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Sleep Tracker")
            .listStyle(.sidebar)
        } detail: {
            selectedTabView
                .navigationBarTitleDisplayMode(.inline)
        }
        .navigationSplitViewStyle(.balanced)
    }

    // MARK: - iPhone Tab Layout

    private var iPhoneTabLayout: some View {
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
    }

    // MARK: - Selected Tab View (for iPad sidebar)

    @ViewBuilder
    private var selectedTabView: some View {
        switch selectedTab {
        case .dashboard:
            DashboardScreen(selectedTab: $selectedTab, audioRecorder: audioRecorder)
        case .sessions:
            SleepTrackingView(audioRecorder: audioRecorder)
        case .recordings:
            RecordingsView(audioRecorder: audioRecorder)
        case .analytics:
            AnalyticsView()
        case .settings:
            SettingsView()
        }
    }

    enum Tab: String, CaseIterable, Identifiable {
        case dashboard, sessions, recordings, analytics, settings

        var id: String { rawValue }

        var title: String {
            switch self {
            case .dashboard: return "Home"
            case .sessions: return "Sessions"
            case .recordings: return "Recordings"
            case .analytics: return "Insights"
            case .settings: return "Settings"
            }
        }

        var icon: String {
            switch self {
            case .dashboard: return "house.fill"
            case .sessions: return "moon.zzz.fill"
            case .recordings: return "waveform"
            case .analytics: return "chart.bar.xaxis"
            case .settings: return "slider.horizontal.3"
            }
        }
    }
}

// MARK: - Onboarding View

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

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
                        OnboardingPageView(page: pages[index], horizontalSizeClass: horizontalSizeClass)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Page Indicator
                HStack(spacing: DeviceInfo.isIPad ? 12 : 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                            .frame(width: DeviceInfo.isIPad ? 12 : 8, height: DeviceInfo.isIPad ? 12 : 8)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, DeviceInfo.isIPad ? 48 : 32)

                // Buttons
                VStack(spacing: 16) {
                    if currentPage < pages.count - 1 {
                        Button {
                            withAnimation {
                                currentPage += 1
                            }
                        } label: {
                            Text("Continue")
                                .font(DeviceInfo.isIPad ? .title3 : .headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: DeviceInfo.isIPad ? 400 : .infinity)
                                .padding(.vertical, DeviceInfo.isIPad ? 20 : 16)
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
                        .font(DeviceInfo.isIPad ? .title3 : .body)
                        .foregroundStyle(.white.opacity(0.7))
                    } else {
                        Button {
                            completeOnboarding()
                        } label: {
                            Text("Get Started")
                                .font(DeviceInfo.isIPad ? .title3 : .headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: DeviceInfo.isIPad ? 400 : .infinity)
                                .padding(.vertical, DeviceInfo.isIPad ? 20 : 16)
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
                .padding(.horizontal, ResponsiveSpacing.containerPadding(horizontalSizeClass))
                .padding(.bottom, DeviceInfo.isIPad ? 64 : 48)
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
    let horizontalSizeClass: UserInterfaceSizeClass?

    var body: some View {
        VStack(spacing: DeviceInfo.isIPad ? 48 : 32) {
            Spacer()

            // Icon
            Image(systemName: page.icon)
                .font(.system(size: DeviceInfo.isIPad ? 120 : 80))
                .foregroundStyle(page.color)
                .padding(DeviceInfo.isIPad ? 60 : 40)
                .background(
                    Circle()
                        .fill(page.color.opacity(0.2))
                        .overlay(
                            Circle()
                                .stroke(page.color.opacity(0.3), lineWidth: DeviceInfo.isIPad ? 3 : 2)
                        )
                )
                .shadow(color: page.color.opacity(0.4), radius: DeviceInfo.isIPad ? 40 : 30, y: 10)

            // Text Content
            VStack(spacing: DeviceInfo.isIPad ? 24 : 16) {
                Text(page.title)
                    .font(ResponsiveFont.largeTitle(horizontalSizeClass))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(ResponsiveFont.headline(horizontalSizeClass))
                    .fontWeight(.medium)
                    .foregroundStyle(page.color)

                Text(page.description)
                    .font(ResponsiveFont.body(horizontalSizeClass))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(DeviceInfo.isIPad ? 6 : 4)
                    .padding(.horizontal, ResponsiveSpacing.containerPadding(horizontalSizeClass))
                    .frame(maxWidth: DeviceInfo.isIPad ? 600 : .infinity)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, ResponsiveSpacing.containerPadding(horizontalSizeClass))
    }
}

#Preview {
    ContentView()
}
