//
//  StandByView.swift
//  open-sleep-tracker
//
//  Apple-style iPad StandBy Mode
//

import SwiftUI

// MARK: - StandBy Mode Main View

struct StandByView: View {
    @ObservedObject var audioRecorder: AudioRecorder
    @StateObject private var settings = StandBySettings()
    @StateObject private var standByState = StandByState()
    @EnvironmentObject var themeManager: ThemeManager

    @Environment(\.dismiss) private var dismiss
    @State private var currentTime = Date()
    @State private var showControls = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Background
            Color.black
                .ignoresSafeArea()

            // Content
            contentLayout
                .opacity(standByState.isDimmed ? 0.3 : 1.0)
                .animation(.easeInOut(duration: 0.5), value: standByState.isDimmed)

            // Page Indicators
            if settings.enabledPages.count > 1 && !showControls {
                VStack {
                    Spacer()
                    PageIndicators(
                        currentPage: standByState.currentPageIndex,
                        totalPages: settings.enabledPages.count
                    )
                    .padding(.bottom, 40)
                }
            }

            // Controls Overlay
            if showControls {
                StandByControls(
                    settings: settings,
                    onClose: { dismiss() },
                    onDismissControls: { showControls = false }
                )
                .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden()
        .persistentSystemOverlays(.hidden)
        .colorMultiply(settings.redTintEnabled ? Color.red.opacity(0.3) : .white)
        .onTapGesture {
            handleTap()
        }
        .onLongPressGesture(minimumDuration: 1.0) {
            showControls.toggle()
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { _ in
                    standByState.recordInteraction()
                }
        )
        .onReceive(timer) { _ in
            currentTime = Date()
            checkAutoDim()
        }
        .onAppear {
            setupStandBy()
        }
        .onDisappear {
            cleanupStandBy()
        }
    }

    // MARK: - Content Layouts

    @ViewBuilder
    private var contentLayout: some View {
        TabView(selection: $standByState.currentPageIndex) {
            ForEach(Array(settings.enabledPages.enumerated()), id: \.element) { index, page in
                pageView(for: page)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func pageView(for page: StandBySettings.StandByPage) -> some View {
        switch page {
        case .clock:
            ClockPage(currentTime: currentTime, isRecording: audioRecorder.isRecording, showSeconds: settings.showSeconds)
        case .widgets:
            WidgetsPage(audioRecorder: audioRecorder, enabledWidgets: settings.enabledWidgets)
        case .recording:
            RecordingPage(currentTime: currentTime, audioRecorder: audioRecorder)
        case .metrics:
            MetricsPage(currentTime: currentTime, audioRecorder: audioRecorder)
        }
    }

    // MARK: - Interaction Handlers

    private func handleTap() {
        standByState.recordInteraction()
    }

    private func checkAutoDim() {
        guard settings.autoDimEnabled else { return }

        let timeSinceInteraction = Date().timeIntervalSince(standByState.lastInteraction)

        if timeSinceInteraction > 30 && !standByState.isDimmed {
            withAnimation(.easeInOut(duration: 2.0)) {
                standByState.isDimmed = true
            }
        }
    }

    private func setupStandBy() {
        standByState.activate()
        UIApplication.shared.isIdleTimerDisabled = settings.keepScreenOn

        if settings.brightness < 1.0 {
            UIScreen.main.brightness = settings.brightness
        }
    }

    private func cleanupStandBy() {
        standByState.deactivate()
        UIApplication.shared.isIdleTimerDisabled = false
    }
}

// MARK: - Page: Clock

struct ClockPage: View {
    let currentTime: Date
    let isRecording: Bool
    let showSeconds: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            StandByClockWidget(time: currentTime, showSeconds: showSeconds, size: .large)

            Spacer()

            if isRecording {
                HStack(spacing: 12) {
                    Circle()
                        .fill(.orange)
                        .frame(width: 12, height: 12)

                    Text("Recording")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.bottom, 60)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Page: Widgets

struct WidgetsPage: View {
    let audioRecorder: AudioRecorder
    let enabledWidgets: [StandBySettings.WidgetType]

    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(enabledWidgets, id: \.self) { widget in
                    StandByWidgetContainer(widget: widget, audioRecorder: audioRecorder)
                        .frame(height: 180)
                }
            }
            .padding(40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Page: Recording

struct RecordingPage: View {
    let currentTime: Date
    let audioRecorder: AudioRecorder

    var body: some View {
        VStack(spacing: 40) {
            StandByClockWidget(time: currentTime, showSeconds: false, size: .small)
                .padding(.top, 40)

            Spacer()

            if audioRecorder.isRecording {
                AudioVisualizerWidget(audioLevel: audioRecorder.audioLevel)
            } else {
                Text("Start recording to see visualization")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }

            if audioRecorder.isRecording {
                DetailedStatsWidget(audioRecorder: audioRecorder)
            }

            Spacer()
        }
        .padding(.horizontal, 60)
    }
}

// MARK: - Page: Metrics

struct MetricsPage: View {
    let currentTime: Date
    let audioRecorder: AudioRecorder

    var body: some View {
        VStack(spacing: 48) {
            Spacer()

            StandByClockWidget(time: currentTime, showSeconds: false, size: .medium)

            if audioRecorder.isRecording {
                RecordingStatusWidget(audioRecorder: audioRecorder)
                SessionStatsWidget(audioRecorder: audioRecorder)
            } else {
                Text("Start recording to see metrics")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()
        }
        .padding(.horizontal, 60)
        .padding(.vertical, 40)
    }
}

// MARK: - Widget: Clock

struct StandByClockWidget: View {
    let time: Date
    let showSeconds: Bool
    let size: ClockSize

    enum ClockSize {
        case small, medium, large

        var fontSize: CGFloat {
            switch self {
            case .small: return 48
            case .medium: return 80
            case .large: return 120
            }
        }

        var dateSize: CGFloat {
            switch self {
            case .small: return 16
            case .medium: return 20
            case .large: return 24
            }
        }
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = showSeconds ? "HH:mm:ss" : "HH:mm"
        return formatter
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter
    }

    var body: some View {
        VStack(spacing: size == .large ? 16 : 12) {
            Text(timeFormatter.string(from: time))
                .font(.system(size: size.fontSize, weight: .thin, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()

            Text(dateFormatter.string(from: time))
                .font(.system(size: size.dateSize, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}

// MARK: - Widget: Recording Status

struct RecordingStatusWidget: View {
    let audioRecorder: AudioRecorder
    @State private var pulse = false

    var body: some View {
        HStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .scaleEffect(pulse ? 1.2 : 1.0)
                    .opacity(pulse ? 0.5 : 0.8)

                Circle()
                    .fill(.orange)
                    .frame(width: 20, height: 20)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    pulse = true
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Recording in Progress")
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                Text(audioRecorder.recordingDuration.formattedDurationDescription)
                    .font(.system(size: 24, weight: .regular, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .monospacedDigit()
            }
        }
    }
}

// MARK: - Widget: Session Stats

struct SessionStatsWidget: View {
    let audioRecorder: AudioRecorder

    var body: some View {
        HStack(spacing: 40) {
            StatItem(
                icon: "waveform",
                label: "Activity",
                value: "\(Int(audioRecorder.audioLevel * 100))%",
                color: audioRecorder.audioLevel > 0.6 ? .orange : .green
            )

            StatItem(
                icon: "clock",
                label: "Duration",
                value: audioRecorder.recordingDuration.formattedDurationDescription,
                color: .blue
            )

            StatItem(
                icon: "checkmark.circle",
                label: "Status",
                value: "Active",
                color: .green
            )
        }
    }

    struct StatItem: View {
        let icon: String
        let label: String
        let value: String
        let color: Color

        var body: some View {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundStyle(color)

                Text(value)
                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)

                Text(label)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }
}

// MARK: - Widget: Audio Visualizer

struct AudioVisualizerWidget: View {
    let audioLevel: Float
    @State private var bars: [CGFloat] = Array(repeating: 0.1, count: 20)

    var body: some View {
        VStack(spacing: 24) {
            HStack(alignment: .center, spacing: 8) {
                ForEach(0..<20, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .frame(width: 12, height: bars[index] * 200)
                        .animation(.easeInOut(duration: 0.3).delay(Double(index) * 0.02), value: bars[index])
                }
            }
            .frame(height: 200)

            Text("Listening for snoring patterns...")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.white.opacity(0.6))
        }
        .onChange(of: audioLevel) { newValue in
            updateBars(level: CGFloat(newValue))
        }
        .onAppear {
            startAnimation()
        }
    }

    private func updateBars(level: CGFloat) {
        for i in 0..<bars.count {
            let randomVariation = CGFloat.random(in: 0.5...1.5)
            bars[i] = max(0.1, level * randomVariation)
        }
    }

    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
            updateBars(level: CGFloat(audioLevel))
        }
    }
}

// MARK: - Widget: Detailed Stats

struct DetailedStatsWidget: View {
    let audioRecorder: AudioRecorder

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 40) {
                DetailedStatItem(
                    value: audioRecorder.recordingDuration.formattedDurationDescription,
                    label: "Session Duration"
                )

                DetailedStatItem(
                    value: "\(Int(audioRecorder.audioLevel * 100))%",
                    label: "Current Activity"
                )

                DetailedStatItem(
                    value: audioRecorder.recordings.count.description,
                    label: "Total Sessions"
                )
            }
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.white.opacity(0.05))
        )
    }

    struct DetailedStatItem: View {
        let value: String
        let label: String

        var body: some View {
            VStack(spacing: 8) {
                Text(value)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()

                Text(label)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Controls Overlay

struct StandByControls: View {
    @ObservedObject var settings: StandBySettings
    let onClose: () -> Void
    let onDismissControls: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismissControls()
                }

            VStack(spacing: 32) {
                Text("StandBy Controls")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                VStack(spacing: 24) {
                    // Brightness Control
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "sun.max.fill")
                                .foregroundStyle(.white)
                            Text("Brightness")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(.white)
                            Spacer()
                            Text("\(Int(settings.brightness * 100))%")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.7))
                        }

                        Slider(value: $settings.brightness, in: 0.1...1.0)
                            .tint(.blue)
                            .onChange(of: settings.brightness) { newValue in
                                UIScreen.main.brightness = newValue
                            }
                    }

                    Divider().background(.white.opacity(0.2))

                    // Red Tint Toggle
                    Toggle(isOn: $settings.redTintEnabled) {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundStyle(.red)
                            Text("Red Tint (Night Mode)")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(.white)
                        }
                    }
                    .tint(.red)

                    // Auto-Dim Toggle
                    Toggle(isOn: $settings.autoDimEnabled) {
                        HStack {
                            Image(systemName: "moon.zzz")
                                .foregroundStyle(.white)
                            Text("Auto-Dim After 30s")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(.white)
                        }
                    }
                    .tint(.blue)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(.white.opacity(0.1))
                )

                Button("Exit StandBy Mode") {
                    onClose()
                }
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.red.opacity(0.8))
                )
            }
            .padding(40)
            .frame(maxWidth: 600)
        }
    }
}

// MARK: - Page Indicators

struct PageIndicators: View {
    let currentPage: Int
    let totalPages: Int

    var body: some View {
        HStack(spacing: 12) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                    .frame(width: index == currentPage ? 10 : 8, height: index == currentPage ? 10 : 8)
                    .animation(.spring(response: 0.3), value: currentPage)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(.ultraThinMaterial.opacity(0.5))
        )
    }
}

// MARK: - Legacy Support

struct StandByBackground: View {
    let style: StandBySettings.BackgroundStyle
    let theme: AppTheme

    var body: some View {
        Color.black
            .ignoresSafeArea()
    }
}

struct AuroraBackground: View {
    var body: some View {
        Color.black
    }
}

struct StarfieldBackground: View {
    var body: some View {
        Color.black
    }
}

struct CompactStatsWidget: View {
    let audioRecorder: AudioRecorder

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            CompactStatRow(icon: "waveform", label: "Activity", value: "\(Int(audioRecorder.audioLevel * 100))%")
            CompactStatRow(icon: "clock", label: "Duration", value: audioRecorder.recordingDuration.formattedDurationDescription)
            CompactStatRow(icon: "mic.fill", label: "Status", value: "Recording")
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.white.opacity(0.05))
        )
    }

    struct CompactStatRow: View {
        let icon: String
        let label: String
        let value: String

        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(width: 32)

                Text(label)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.white.opacity(0.6))

                Spacer()

                Text(value)
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }
        }
    }
}

#Preview {
    StandByView(audioRecorder: AudioRecorder())
        .environmentObject(ThemeManager())
}
