//
//  ContentView.swift
//  open-sleep-tracker
//
//  Apple-style navigation
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
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
        .preferredColorScheme(themeManager.selectedTheme.colorScheme)
        .tint(.blue)
        .environmentObject(themeManager)
        .sheet(isPresented: $showOnboarding) {
            OnboardingView(isPresented: $showOnboarding)
                .environmentObject(themeManager)
        }
        .onAppear {
            if !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
                showOnboarding = true
            }
        }
    }

    // MARK: - iPad Layout

    private var iPadLayout: some View {
        NavigationSplitView {
            List {
                ForEach(Tab.allCases) { tab in
                    Button {
                        selectedTab = tab
                    } label: {
                        Label(tab.title, systemImage: tab.icon)
                            .foregroundStyle(selectedTab == tab ? Color.accentColor : .primary)
                    }
                }
            }
            .navigationTitle("Sleep")
            .listStyle(.sidebar)
        } detail: {
            selectedTabView
        }
        .navigationSplitViewStyle(.balanced)
    }

    // MARK: - iPhone Layout

    private var iPhoneLayout: some View {
        TabView(selection: $selectedTab) {
            DashboardScreen(selectedTab: $selectedTab, audioRecorder: audioRecorder)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.dashboard)

            SleepTrackingView(audioRecorder: audioRecorder)
                .tabItem {
                    Label("Sleep", systemImage: "moon.zzz.fill")
                }
                .tag(Tab.sessions)

            RecordingsView(audioRecorder: audioRecorder)
                .tabItem {
                    Label("Recordings", systemImage: "waveform")
                }
                .tag(Tab.recordings)

            AnalyticsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.bar.fill")
                }
                .tag(Tab.analytics)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
        }
    }

    // MARK: - Selected Tab View

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

    // MARK: - Tab Enum

    enum Tab: String, CaseIterable, Identifiable {
        case dashboard, sessions, recordings, analytics, settings

        var id: String { rawValue }

        var title: String {
            switch self {
            case .dashboard: return "Home"
            case .sessions: return "Sleep"
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
            case .analytics: return "chart.bar.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
}

// MARK: - Onboarding View

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Track Your Sleep",
            subtitle: "Understand your rest",
            description: "Monitor your sleep patterns and get personalized insights to improve your rest.",
            icon: "moon.zzz.fill",
            color: .blue
        ),
        OnboardingPage(
            title: "Smart Detection",
            subtitle: "AI-powered analysis",
            description: "Advanced algorithms detect snoring and other patterns to give you accurate data.",
            icon: "waveform.circle.fill",
            color: .green
        ),
        OnboardingPage(
            title: "Health Integration",
            subtitle: "Connected wellness",
            description: "Sync with Apple Health for a complete picture of your sleep health.",
            icon: "heart.text.square",
            color: .teal
        ),
        OnboardingPage(
            title: "Privacy First",
            subtitle: "Your data stays yours",
            description: "All processing happens on-device. Your sleep data is never shared.",
            icon: "lock.shield.fill",
            color: .purple
        )
    ]

    var body: some View {
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
                        .fill(index == currentPage ? Color.primary : Color.secondary.opacity(0.3))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 32)

            // Buttons
            VStack(spacing: 12) {
                if currentPage < pages.count - 1 {
                    Button {
                        withAnimation {
                            currentPage += 1
                        }
                    } label: {
                        Text("Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)

                    Button("Skip") {
                        completeOnboarding()
                    }
                    .foregroundStyle(.secondary)
                } else {
                    Button {
                        completeOnboarding()
                    } label: {
                        Text("Get Started")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
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
                .font(.system(size: 72))
                .foregroundStyle(page.color)
                .padding(40)
                .background(
                    Circle()
                        .fill(page.color.opacity(0.12))
                )

            // Text
            VStack(spacing: 12) {
                Text(page.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.headline)
                    .foregroundStyle(page.color)

                Text(page.description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
