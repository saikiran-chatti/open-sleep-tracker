//
//  AnalyticsView.swift
//  open-sleep-tracker
//
//  Created by AI Assistant on 10/16/25.
//

import SwiftUI
import Charts

struct AnalyticsView: View {
    @ObservedObject var analysisAgent: SleepPatternAnalysisAgent
    @State private var selectedTimeframe: TimeFrame = .week
    
    enum TimeFrame: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Text("Sleep Analytics")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Understand your sleep patterns")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 20)
                
                // Timeframe Selector
                GlassCardView {
                    VStack(spacing: 15) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                            Text("Time Period")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        Picker("Timeframe", selection: $selectedTimeframe) {
                            ForEach(TimeFrame.allCases, id: \.self) { timeframe in
                                Text(timeframe.rawValue).tag(timeframe)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                // Sleep Quality Overview
                if let insights = analysisAgent.sleepInsights {
                    GlassCardView {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "chart.bar.fill")
                                    .foregroundColor(.green)
                                Text("Sleep Quality Overview")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            VStack(spacing: 20) {
                                // Overall quality score
                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Overall Quality")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text("\(Int(insights.sleepQuality * 100))%")
                                            .font(.title)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                    }
                                    
                                    Spacer()
                                    
                                    // Quality indicator
                                    Circle()
                                        .fill(qualityColor(insights.sleepQuality))
                                        .frame(width: 20, height: 20)
                                }
                                
                                // Quality trend
                                if let trend = insights.trends["sleep_quality_trend"] {
                                    HStack {
                                        Image(systemName: trend > 0 ? "arrow.up.right" : "arrow.down.right")
                                            .foregroundColor(trend > 0 ? .green : .red)
                                        
                                        Text(trend > 0 ? "Improving" : "Declining")
                                            .font(.subheadline)
                                            .foregroundColor(trend > 0 ? .green : .red)
                                        
                                        Spacer()
                                        
                                        Text("\(String(format: "%.1f", abs(trend * 100)))%")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Snore Analysis
                if let insights = analysisAgent.sleepInsights {
                    GlassCardView {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "waveform.path.ecg")
                                    .foregroundColor(.orange)
                                Text("Snore Analysis")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            VStack(spacing: 15) {
                                // Snore frequency
                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Snore Frequency")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text("\(String(format: "%.1f", insights.snoreFrequency))")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundColor(.primary)
                                        
                                        Text("events per hour")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    // Frequency indicator
                                    Circle()
                                        .fill(snoreFrequencyColor(insights.snoreFrequency))
                                        .frame(width: 20, height: 20)
                                }
                                
                                // Snore trend
                                if let trend = insights.trends["snore_frequency_trend"] {
                                    HStack {
                                        Image(systemName: trend > 0 ? "arrow.up.right" : "arrow.down.right")
                                            .foregroundColor(trend > 0 ? .red : .green)
                                        
                                        Text(trend > 0 ? "Increasing" : "Decreasing")
                                            .font(.subheadline)
                                            .foregroundColor(trend > 0 ? .red : .green)
                                        
                                        Spacer()
                                        
                                        Text("\(String(format: "%.1f", abs(trend)))")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Weekly Trends Chart
                if !analysisAgent.weeklyTrends.isEmpty {
                    GlassCardView {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .foregroundColor(.blue)
                                Text("Weekly Trends")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            // Simple bar chart representation
                            VStack(spacing: 10) {
                                ForEach(Array(analysisAgent.weeklyTrends.keys.sorted()), id: \.self) { week in
                                    HStack {
                                        Text(week)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .frame(width: 60, alignment: .leading)
                                        
                                        GeometryReader { geometry in
                                            HStack {
                                                RoundedRectangle(cornerRadius: 4)
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [.blue, .purple],
                                                            startPoint: .leading,
                                                            endPoint: .trailing
                                                        )
                                                    )
                                                    .frame(width: geometry.size.width * (analysisAgent.weeklyTrends[week] ?? 0))
                                                
                                                Spacer()
                                            }
                                        }
                                        .frame(height: 20)
                                        
                                        Text("\(Int((analysisAgent.weeklyTrends[week] ?? 0) * 100))%")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                            .frame(width: 40, alignment: .trailing)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Recommendations
                if let insights = analysisAgent.sleepInsights, !insights.recommendations.isEmpty {
                    GlassCardView {
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("Recommendations")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(insights.recommendations, id: \.self) { recommendation in
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
        .onAppear {
            analysisAgent.analyzeSleepPatterns()
        }
    }
    
    private func qualityColor(_ quality: Double) -> Color {
        switch quality {
        case 0.8...1.0:
            return .green
        case 0.6..<0.8:
            return .yellow
        default:
            return .red
        }
    }
    
    private func snoreFrequencyColor(_ frequency: Double) -> Color {
        switch frequency {
        case 0..<2:
            return .green
        case 2..<5:
            return .yellow
        default:
            return .red
        }
    }
}

#Preview {
    AnalyticsView(analysisAgent: SleepPatternAnalysisAgent())
}