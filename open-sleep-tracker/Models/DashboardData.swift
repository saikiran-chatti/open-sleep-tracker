//
//  DashboardData.swift
//  open-sleep-tracker
//
//  Created by AI Agent on 11/22/25.
//

import SwiftUI

// MARK: - Dashboard Data Model

struct DashboardData {
    struct SleepSummary {
        let headline: String
        let dateRangeLabel: String
        let totalSleep: TimeInterval
        let snoreEvents: Int
        let filteredPercentage: Int
        let deepSleepPercentage: Int
        let remSleepPercentage: Int
        let trend: Double
        let sleepScore: Int

        var formattedDuration: String {
            totalSleep.formattedDurationDescription
        }

        var trendDescription: String {
            trend >= 0 ? "Sleep score up \(Int(trend))% vs last week" : "Sleep score down \(Int(abs(trend)))% vs last week"
        }
    }

    struct Highlight: Identifiable {
        let id = UUID()
        let title: String
        let caption: String
        let icon: String
        let tint: Color
        let trend: Trend
    }

    enum Trend {
        case up(Int)
        case down(Int)
        case steady
    }

    struct Agent: Identifiable {
        enum State {
            case running, syncing, idle, attention

            var label: String {
                switch self {
                case .running: return "Active"
                case .syncing: return "Syncing"
                case .idle: return "Idle"
                case .attention: return "Action Needed"
                }
            }

            var icon: String {
                switch self {
                case .running: return "sparkles"
                case .syncing: return "arrow.triangle.2.circlepath"
                case .idle: return "pause.circle"
                case .attention: return "exclamationmark.triangle.fill"
                }
            }

            var color: Color {
                switch self {
                case .running: return .accentGreen
                case .syncing: return .accentBlue
                case .idle: return .white.opacity(0.6)
                case .attention: return .accentOrange
                }
            }
        }

        let id = UUID()
        let name: String
        let description: String
        let icon: String
        let tint: Color
        let state: State
    }

    struct Insight: Identifiable {
        struct Action {
            let label: String
        }

        let id = UUID()
        let title: String
        let detail: String
        let icon: String
        let tint: Color
        let action: Action?
    }

    struct SleepEvent: Identifiable {
        let id = UUID()
        let timeLabel: String
        let title: String
        let description: String
        let intensity: Int
        let tint: Color
        let agentLabel: String
        let progress: Double
        let agentState: Agent.State

        var agentLabelShort: String {
            agentLabel
        }
    }

    struct SessionSchedule {
        struct Checkpoint: Identifiable {
            let id = UUID()
            let timeLabel: String
            let phase: String
            let description: String
            let icon: String
            let tint: Color
        }

        struct Routine: Identifiable {
            let id = UUID()
            let title: String
            let detail: String
            let icon: String
            let tint: Color
        }

        struct EnvironmentReading: Identifiable {
            let id = UUID()
            let title: String
            let value: String
            let detail: String
            let icon: String
            let status: String
            let statusIcon: String
            let tint: Color
        }

        let sleepWindow: String
        let summary: String
        let focus: String
        let checkpoints: [Checkpoint]
        let routines: [Routine]
        let environmentReadings: [EnvironmentReading]
    }

    struct Analytics {
        struct DistributionPoint: Identifiable {
            let id = UUID()
            let label: String
            let valueText: String
            let progress: Double
            let tint: Color
        }

        struct Trend: Identifiable {
            let id = UUID()
            let title: String
            let detail: String
            let icon: String
            let tint: Color
            let trend: DashboardData.Trend
            let context: String
            let confidence: Int
        }

        struct FocusArea: Identifiable {
            let id = UUID()
            let title: String
            let detail: String
            let icon: String
            let tint: Color
            let actionLabel: String
        }

        let sleepScoreAverage: Double
        let caption: String
        let distribution: [DistributionPoint]
        let trends: [Trend]
        let focusAreas: [FocusArea]
    }

    let summary: SleepSummary
    let highlights: [Highlight]
    let agents: [Agent]
    let insights: [Insight]
    let timeline: [SleepEvent]
    let schedule: SessionSchedule
    let analytics: Analytics

    // MARK: - Sample Data

    static let sample: DashboardData = {
        DashboardData(
            summary: SleepSummary(
                headline: "Rested & Recovered",
                dateRangeLabel: "Nov 21 → Nov 22",
                totalSleep: 7 * 3600 + 42 * 60,
                snoreEvents: 12,
                filteredPercentage: 82,
                deepSleepPercentage: 27,
                remSleepPercentage: 19,
                trend: 12,
                sleepScore: 88
            ),
            highlights: [
                Highlight(
                    title: "Snore intensity down",
                    caption: "Audio Classification Agent reduced false positives by refining thresholds.",
                    icon: "waveform.badge.minus",
                    tint: .accentGreen,
                    trend: .up(18)
                ),
                Highlight(
                    title: "Heart rate coherence",
                    caption: "Health Integration Agent detected steady HRV patterns during deep sleep.",
                    icon: "heart.fill",
                    tint: .accentTeal,
                    trend: .steady
                ),
                Highlight(
                    title: "Sleep schedule compliance",
                    caption: "Notification Agent maintained 92% adherence to your 11pm wind-down routine.",
                    icon: "bell.badge",
                    tint: .accentPurple,
                    trend: .up(9)
                ),
                Highlight(
                    title: "StandBy ambient success",
                    caption: "StandBy Intelligence Agent kept display luminosity optimal all night.",
                    icon: "display",
                    tint: .accentBlue,
                    trend: .down(3)
                )
            ],
            agents: [
                Agent(
                    name: "Audio Classification",
                    description: "Real-time snore detection with MLSoundClassifier tuned for your profile.",
                    icon: "waveform.circle.fill",
                    tint: .accentGreen,
                    state: .running
                ),
                Agent(
                    name: "Sleep Pattern Analysis",
                    description: "Predicts nightly quality using 60-day trend modeling and time-series analysis.",
                    icon: "chart.xyaxis.line",
                    tint: .accentTeal,
                    state: .running
                ),
                Agent(
                    name: "Health Integration",
                    description: "Syncs heart, respiratory, and motion signals via HealthKit and Apple Watch.",
                    icon: "heart.text.square",
                    tint: .accentPurple,
                    state: .syncing
                ),
                Agent(
                    name: "Intelligent Notifications",
                    description: "Delivers adaptive reminders, wake windows, and StandBy widgets.",
                    icon: "bell.badge.waveform.fill",
                    tint: .accentBlue,
                    state: .running
                ),
                Agent(
                    name: "Data Synchronization",
                    description: "CloudKit + Core Data pipeline with conflict resolution across devices.",
                    icon: "arrow.triangle.branch",
                    tint: .accentOrange,
                    state: .attention
                ),
                Agent(
                    name: "StandBy Intelligence",
                    description: "Curates nightstand display with ambient cues and sleep progress.",
                    icon: "display",
                    tint: .accentPurple,
                    state: .idle
                )
            ],
            insights: [
                Insight(
                    title: "Wind-down earlier tonight",
                    detail: "Falling asleep 20 minutes earlier boosts predicted sleep quality by 9%.",
                    icon: "sparkles",
                    tint: .accentGreen,
                    action: .init(label: "Add to schedule")
                ),
                Insight(
                    title: "Enable AirPlay white noise",
                    detail: "Audio Classification Agent suggests a 35 dB background noise to reduce snore probability.",
                    icon: "speaker.wave.2.circle",
                    tint: .accentBlue,
                    action: .init(label: "Start playback")
                ),
                Insight(
                    title: "Consider quieter bedding",
                    detail: "Movement spikes correlate with snore clusters. Try the \"CalmNight\" pillow preset.",
                    icon: "bed.double.circle.fill",
                    tint: .accentPurple,
                    action: nil
                )
            ],
            timeline: [
                SleepEvent(
                    timeLabel: "11:24 PM",
                    title: "Session Started",
                    description: "Audio Classification Agent calibrated to current room acoustics.",
                    intensity: 1,
                    tint: .accentBlue,
                    agentLabel: "Data Sync → CloudKit",
                    progress: 0.12,
                    agentState: .running
                ),
                SleepEvent(
                    timeLabel: "12:10 AM",
                    title: "Light snoring detected",
                    description: "Low-intensity snore pattern categorized as Type A. Filtered 3 ambient noises.",
                    intensity: 3,
                    tint: .accentOrange,
                    agentLabel: "Audio Agent",
                    progress: 0.3,
                    agentState: .running
                ),
                SleepEvent(
                    timeLabel: "02:08 AM",
                    title: "Deep sleep achieved",
                    description: "Sleep Pattern Analysis Agent validated >25% deep sleep streak.",
                    intensity: 4,
                    tint: .accentTeal,
                    agentLabel: "Sleep Pattern",
                    progress: 0.65,
                    agentState: .running
                ),
                SleepEvent(
                    timeLabel: "04:46 AM",
                    title: "High snore cluster",
                    description: "Triggered StandBy ambient dimming and recorded for personalization.",
                    intensity: 5,
                    tint: .accentOrange,
                    agentLabel: "Audio + StandBy",
                    progress: 0.88,
                    agentState: .attention
                ),
                SleepEvent(
                    timeLabel: "06:45 AM",
                    title: "Smart wake suggestion",
                    description: "Notification Agent queued gentle wake within 10-minute light-sleep window.",
                    intensity: 2,
                    tint: .accentPurple,
                    agentLabel: "Notification Agent",
                    progress: 1.0,
                    agentState: .running
                )
            ],
            schedule: SessionSchedule.sample,
            analytics: Analytics.sample
        )
    }()

    static func sampleNextPhase() -> DashboardData {
        .init(
            summary: SleepSummary(
                headline: "Recovery Mode",
                dateRangeLabel: "Nov 22 → Nov 23",
                totalSleep: 6 * 3600 + 58 * 60,
                snoreEvents: 18,
                filteredPercentage: 76,
                deepSleepPercentage: 22,
                remSleepPercentage: 17,
                trend: -6,
                sleepScore: 74
            ),
            highlights: sample.highlights.shuffled(),
            agents: sample.agents.shuffled(),
            insights: sample.insights.shuffled(),
            timeline: sample.timeline.shuffled(),
            schedule: SessionSchedule.optimized,
            analytics: Analytics.alternative
        )
    }
}

// MARK: - Session Schedule Extensions

extension DashboardData.SessionSchedule {
    static let sample: DashboardData.SessionSchedule = DashboardData.SessionSchedule(
        sleepWindow: "11:00 PM – 6:30 AM",
        summary: "Health Integration Agent aligned your target sleep with heart rate recovery windows.",
        focus: "Recovery",
        checkpoints: [
            .init(timeLabel: "10:30 PM", phase: "Wind-down", description: "Enable StandBy ambient display and start Calm Breathing routine.", icon: "wind", tint: .accentPurple),
            .init(timeLabel: "11:00 PM", phase: "Lights out", description: "Audio Classification Agent calibrates and begins live monitoring.", icon: "moon.stars.fill", tint: .accentBlue),
            .init(timeLabel: "3:30 AM", phase: "Snore review", description: "Agent will adjust thresholds if snore intensity >60%.", icon: "waveform.path.ecg", tint: .accentOrange),
            .init(timeLabel: "6:10 AM", phase: "Smart wake", description: "Wake suggestion triggered at optimal light-sleep phase.", icon: "alarm", tint: .accentGreen)
        ],
        routines: [
            .init(title: "Hydration check", detail: "Drink water to stabilize respiratory patterns.", icon: "drop.fill", tint: .accentTeal),
            .init(title: "Activate white noise", detail: "Turn on fan or AirPlay ambient noise at 35 dB.", icon: "speaker.wave.2", tint: .accentBlue),
            .init(title: "Place Apple Watch", detail: "Ensure watch is charging for overnight metrics.", icon: "applewatch.watchface", tint: .accentPurple)
        ],
        environmentReadings: [
            .init(title: "Bedroom Temp", value: "67°F", detail: "Ideal range for reduced snoring.", icon: "thermometer.medium", status: "Optimal", statusIcon: "checkmark.circle", tint: .accentGreen),
            .init(title: "Ambient Noise", value: "28 dB", detail: "Quiet; white noise optional.", icon: "ear.fill", status: "Stable", statusIcon: "waveform", tint: .accentBlue),
            .init(title: "Air Quality", value: "AQI 12", detail: "Low irritants detected.", icon: "leaf", status: "Clear", statusIcon: "leaf.fill", tint: .accentTeal)
        ]
    )

    static let optimized: DashboardData.SessionSchedule = DashboardData.SessionSchedule(
        sleepWindow: "10:45 PM – 6:15 AM",
        summary: "Adjusted earlier bedtime to improve deep sleep accumulation.",
        focus: "Deep Sleep",
        checkpoints: sample.checkpoints.shuffled(),
        routines: sample.routines.shuffled(),
        environmentReadings: sample.environmentReadings
    )
}

// MARK: - Analytics Extensions

extension DashboardData.Analytics {
    static let sample: DashboardData.Analytics = DashboardData.Analytics(
        sleepScoreAverage: 86,
        caption: "Week of Nov 15 – Nov 21",
        distribution: [
            .init(label: "Deep Sleep", valueText: "26%", progress: 0.26, tint: .accentTeal),
            .init(label: "REM Sleep", valueText: "19%", progress: 0.19, tint: .accentPurple),
            .init(label: "Snore-free", valueText: "78%", progress: 0.78, tint: .accentGreen)
        ],
        trends: [
            .init(
                title: "Evening caffeine impact",
                detail: "Snore events increased 24% on days with caffeine past 3 PM.",
                icon: "cup.and.saucer.fill",
                tint: .accentOrange,
                trend: .down(24),
                context: "Audio Classification Agent",
                confidence: 82
            ),
            .init(
                title: "Movement vs. snore clusters",
                detail: "StandBy Agent detected motion spikes preceding 62% of snore clusters.",
                icon: "figure.walk.motion",
                tint: .accentBlue,
                trend: .steady,
                context: "StandBy Intelligence",
                confidence: 74
            )
        ],
        focusAreas: [
            .init(
                title: "Evening routine",
                detail: "Introduce 10-min meditation before bedtime to lower snore intensity.",
                icon: "person.sitting",
                tint: .accentPurple,
                actionLabel: "Add meditation"
            ),
            .init(
                title: "Air quality",
                detail: "Open window 10 minutes pre-sleep; reduces snore probability by 12%.",
                icon: "wind",
                tint: .accentTeal,
                actionLabel: "Set reminder"
            )
        ]
    )

    static let alternative: DashboardData.Analytics = DashboardData.Analytics(
        sleepScoreAverage: 79,
        caption: "Week of Nov 22 – Nov 28",
        distribution: sample.distribution.reversed(),
        trends: sample.trends.reversed(),
        focusAreas: sample.focusAreas.reversed()
    )
}
