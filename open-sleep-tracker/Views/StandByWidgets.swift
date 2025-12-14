//
//  StandByWidgets.swift
//  open-sleep-tracker
//
//  Apple-style StandBy widgets
//

import SwiftUI

// MARK: - Widget Container

struct StandByWidgetContainer: View {
    let widget: StandBySettings.WidgetType
    let audioRecorder: AudioRecorder

    var body: some View {
        Group {
            switch widget {
            case .sleepScore:
                SleepScoreWidget()
            case .previousNight:
                PreviousNightWidget()
            case .environment:
                EnvironmentWidget()
            case .recordings:
                RecordingsWidget(audioRecorder: audioRecorder)
            case .sleepGoals:
                SleepGoalsWidget()
            case .sleepStreak:
                SleepStreakWidget()
            case .weeklyTrend:
                WeeklyTrendWidget()
            case .activeAgents:
                ActiveAgentsWidget()
            case .heartRate:
                HeartRateWidget()
            case .bedtimeCountdown:
                BedtimeCountdownWidget()
            }
        }
    }
}

// MARK: - Sleep Score Widget

struct SleepScoreWidget: View {
    @State private var sleepScore: Int = DashboardData.sample.summary.sleepScore

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "gauge.with.needle")
                    .foregroundStyle(.blue)
                Text("Sleep Score")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
            }

            ZStack {
                Circle()
                    .stroke(.white.opacity(0.1), lineWidth: 8)

                Circle()
                    .trim(from: 0, to: CGFloat(sleepScore) / 100.0)
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                Text("\(sleepScore)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .frame(height: 80)

            Text("7-day average")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.05))
        )
    }
}

// MARK: - Previous Night Widget

struct PreviousNightWidget: View {
    @State private var previousNight = DashboardData.sample.summary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "moon.zzz")
                    .foregroundStyle(.purple)
                Text("Last Night")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
            }

            Text(previousNight.formattedDuration)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            HStack(spacing: 8) {
                Label("\(previousNight.deepSleepPercentage)%", systemImage: "sparkles")
                    .font(.caption)
                    .foregroundStyle(.teal)
                Text("deep")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))

                Spacer()

                Label("\(previousNight.snoreEvents)", systemImage: "waveform")
                    .font(.caption)
                    .foregroundStyle(.orange)
                Text("events")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.05))
        )
    }
}

// MARK: - Environment Widget

struct EnvironmentWidget: View {
    @State private var environment = DashboardData.SessionSchedule.sample.environmentReadings

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "thermometer.medium")
                    .foregroundStyle(.green)
                Text("Environment")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
            }

            if let temp = environment.first(where: { $0.title == "Temperature" }),
               let humidity = environment.first(where: { $0.title == "Humidity" }) {
                VStack(spacing: 8) {
                    HStack {
                        Text(temp.value)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                        Text("Temperature")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.5))
                        Spacer()
                    }

                    HStack {
                        Text(humidity.value)
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                        Text("Humidity")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.5))
                        Spacer()
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.05))
        )
    }
}

// MARK: - Recordings Widget

struct RecordingsWidget: View {
    @ObservedObject var audioRecorder: AudioRecorder

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "waveform")
                    .foregroundStyle(.orange)
                Text("Recordings")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
            }

            Text("\(audioRecorder.recordings.count)")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("Total sessions")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))

            if audioRecorder.isRecording {
                HStack(spacing: 8) {
                    Circle()
                        .fill(.orange)
                        .frame(width: 8, height: 8)
                    Text("Recording now...")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.05))
        )
    }
}

// MARK: - Sleep Goals Widget

struct SleepGoalsWidget: View {
    @State private var progress: Double = 0.75

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "target")
                    .foregroundStyle(.teal)
                Text("Sleep Goal")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("6h 30m / 8h 0m")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.white.opacity(0.1))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [.teal, .green],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 8)
                    }
                }
                .frame(height: 8)

                Text("\(Int(progress * 100))% of goal")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.05))
        )
    }
}

// MARK: - Sleep Streak Widget

struct SleepStreakWidget: View {
    @State private var streak: Int = 7

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "flame")
                    .foregroundStyle(.orange)
                Text("Sleep Streak")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(streak)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("nights")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }

            Text("Keep it going!")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.05))
        )
    }
}

// MARK: - Weekly Trend Widget

struct WeeklyTrendWidget: View {
    @State private var scores = [82, 78, 85, 91, 76, 88, 86]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(.blue)
                Text("This Week")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(.green)
            }

            HStack(alignment: .bottom, spacing: 4) {
                ForEach(0..<7, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: CGFloat(scores[index]) * 0.4)
                }
            }
            .frame(height: 40)

            Text("Avg. \(scores.reduce(0, +) / scores.count)")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.05))
        )
    }
}

// MARK: - Active Agents Widget

struct ActiveAgentsWidget: View {
    @State private var agents = DashboardData.sample.agents

    private var activeCount: Int {
        agents.filter { $0.state == .running }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "cpu.fill")
                    .foregroundStyle(.purple)
                Text("AI Agents")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(activeCount)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("/ \(agents.count)")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Text("agents active")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.05))
        )
    }
}

// MARK: - Heart Rate Widget

struct HeartRateWidget: View {
    @State private var heartRate: Int = 62

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                Text("Heart Rate")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(heartRate)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("BPM")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }

            Text("Resting")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.05))
        )
    }
}

// MARK: - Bedtime Countdown Widget

struct BedtimeCountdownWidget: View {
    @State private var timeUntilBedtime: TimeInterval = 3600 * 2.5

    private var formattedTime: String {
        let hours = Int(timeUntilBedtime) / 3600
        let minutes = (Int(timeUntilBedtime) % 3600) / 60

        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.badge.checkmark")
                    .foregroundStyle(.blue)
                Text("Bedtime")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
            }

            Text(formattedTime)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text("until 10:30 PM")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.05))
        )
    }
}
