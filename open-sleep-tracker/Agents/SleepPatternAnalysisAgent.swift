//
//  SleepPatternAnalysisAgent.swift
//  open-sleep-tracker
//
//  Created by AI Assistant on 10/16/25.
//

import Foundation
import CoreData
import Combine

@MainActor
class SleepPatternAnalysisAgent: ObservableObject {
    @Published var sleepInsights: SleepInsights?
    @Published var weeklyTrends: [String: Double] = [:]
    @Published var monthlyTrends: [String: Double] = [:]
    @Published var recommendations: [String] = []
    
    private let coreDataStack = CoreDataStack.shared
    private var cancellables = Set<AnyCancellable>()
    
    func analyzeSleepPatterns() {
        fetchRecentSleepSessions { [weak self] sessions in
            self?.processSleepSessions(sessions)
        }
    }
    
    private func fetchRecentSleepSessions(completion: @escaping ([SleepSession]) -> Void) {
        let context = coreDataStack.viewContext
        let request: NSFetchRequest<SleepSession> = SleepSession.fetchRequest()
        
        // Fetch last 30 days of sleep sessions
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        request.predicate = NSPredicate(format: "startTime >= %@", thirtyDaysAgo as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "startTime", ascending: false)]
        
        do {
            let sessions = try context.fetch(request)
            completion(sessions)
        } catch {
            print("Failed to fetch sleep sessions: \(error)")
            completion([])
        }
    }
    
    private func processSleepSessions(_ sessions: [SleepSession]) {
        guard !sessions.isEmpty else { return }
        
        let sleepQuality = calculateAverageSleepQuality(sessions)
        let snoreFrequency = calculateSnoreFrequency(sessions)
        let correlations = analyzeCorrelations(sessions)
        let trends = calculateTrends(sessions)
        let recommendations = generateRecommendations(sessions, sleepQuality: sleepQuality, snoreFrequency: snoreFrequency)
        
        sleepInsights = SleepInsights(
            sleepQuality: sleepQuality,
            snoreFrequency: snoreFrequency,
            correlationWithHealth: correlations,
            recommendations: recommendations,
            trends: trends
        )
        
        self.recommendations = recommendations
        self.weeklyTrends = calculateWeeklyTrends(sessions)
        self.monthlyTrends = calculateMonthlyTrends(sessions)
    }
    
    private func calculateAverageSleepQuality(_ sessions: [SleepSession]) -> Double {
        let totalQuality = sessions.reduce(0.0) { $0 + $1.sleepQuality }
        return totalQuality / Double(sessions.count)
    }
    
    private func calculateSnoreFrequency(_ sessions: [SleepSession]) -> Double {
        let totalSnoreEvents = sessions.reduce(0) { $0 + Int($1.totalSnoreEvents) }
        let totalSleepHours = sessions.reduce(0.0) { $0 + $1.duration / 3600 }
        
        guard totalSleepHours > 0 else { return 0.0 }
        return Double(totalSnoreEvents) / totalSleepHours
    }
    
    private func analyzeCorrelations(_ sessions: [SleepSession]) -> [String: Double] {
        var correlations: [String: Double] = [:]
        
        // Analyze correlation between snore events and sleep quality
        let snoreIntensities = sessions.map { $0.averageSnoreIntensity }
        let sleepQualities = sessions.map { $0.sleepQuality }
        
        if snoreIntensities.count > 1 && sleepQualities.count > 1 {
            let correlation = calculatePearsonCorrelation(snoreIntensities, sleepQualities)
            correlations["snore_intensity_vs_sleep_quality"] = correlation
        }
        
        // Analyze correlation between sleep duration and quality
        let durations = sessions.map { $0.duration / 3600 } // Convert to hours
        if durations.count > 1 && sleepQualities.count > 1 {
            let correlation = calculatePearsonCorrelation(durations, sleepQualities)
            correlations["duration_vs_sleep_quality"] = correlation
        }
        
        return correlations
    }
    
    private func calculatePearsonCorrelation(_ x: [Double], _ y: [Double]) -> Double {
        guard x.count == y.count, x.count > 1 else { return 0.0 }
        
        let n = Double(x.count)
        let sumX = x.reduce(0, +)
        let sumY = y.reduce(0, +)
        let sumXY = zip(x, y).map(*).reduce(0, +)
        let sumX2 = x.map { $0 * $0 }.reduce(0, +)
        let sumY2 = y.map { $0 * $0 }.reduce(0, +)
        
        let numerator = n * sumXY - sumX * sumY
        let denominator = sqrt((n * sumX2 - sumX * sumX) * (n * sumY2 - sumY * sumY))
        
        guard denominator != 0 else { return 0.0 }
        return numerator / denominator
    }
    
    private func calculateTrends(_ sessions: [SleepSession]) -> [String: Double] {
        var trends: [String: Double] = [:]
        
        // Calculate trend for sleep quality over time
        let sortedSessions = sessions.sorted { $0.startTime < $1.startTime }
        if sortedSessions.count > 1 {
            let firstHalf = Array(sortedSessions.prefix(sortedSessions.count / 2))
            let secondHalf = Array(sortedSessions.suffix(sortedSessions.count / 2))
            
            let firstHalfQuality = firstHalf.reduce(0.0) { $0 + $1.sleepQuality } / Double(firstHalf.count)
            let secondHalfQuality = secondHalf.reduce(0.0) { $0 + $1.sleepQuality } / Double(secondHalf.count)
            
            trends["sleep_quality_trend"] = secondHalfQuality - firstHalfQuality
        }
        
        // Calculate trend for snore frequency over time
        if sortedSessions.count > 1 {
            let firstHalf = Array(sortedSessions.prefix(sortedSessions.count / 2))
            let secondHalf = Array(sortedSessions.suffix(sortedSessions.count / 2))
            
            let firstHalfSnore = firstHalf.reduce(0) { $0 + Int($1.totalSnoreEvents) }
            let secondHalfSnore = secondHalf.reduce(0) { $0 + Int($1.totalSnoreEvents) }
            
            let firstHalfHours = firstHalf.reduce(0.0) { $0 + $1.duration / 3600 }
            let secondHalfHours = secondHalf.reduce(0.0) { $0 + $1.duration / 3600 }
            
            let firstHalfFreq = firstHalfHours > 0 ? Double(firstHalfSnore) / firstHalfHours : 0
            let secondHalfFreq = secondHalfHours > 0 ? Double(secondHalfSnore) / secondHalfHours : 0
            
            trends["snore_frequency_trend"] = secondHalfFreq - firstHalfFreq
        }
        
        return trends
    }
    
    private func calculateWeeklyTrends(_ sessions: [SleepSession]) -> [String: Double] {
        let calendar = Calendar.current
        let now = Date()
        var weeklyData: [String: Double] = [:]
        
        for i in 0..<4 { // Last 4 weeks
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -i, to: now) ?? now
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? now
            
            let weekSessions = sessions.filter { session in
                session.startTime >= weekStart && session.startTime < weekEnd
            }
            
            if !weekSessions.isEmpty {
                let weekQuality = weekSessions.reduce(0.0) { $0 + $1.sleepQuality } / Double(weekSessions.count)
                _ = calculateSnoreFrequency(weekSessions)
                
                let weekKey = "Week \(4 - i)"
                weeklyData[weekKey] = weekQuality
            }
        }
        
        return weeklyData
    }
    
    private func calculateMonthlyTrends(_ sessions: [SleepSession]) -> [String: Double] {
        let calendar = Calendar.current
        let now = Date()
        var monthlyData: [String: Double] = [:]
        
        for i in 0..<6 { // Last 6 months
            let monthStart = calendar.date(byAdding: .month, value: -i, to: now) ?? now
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) ?? now
            
            let monthSessions = sessions.filter { session in
                session.startTime >= monthStart && session.startTime < monthEnd
            }
            
            if !monthSessions.isEmpty {
                let monthQuality = monthSessions.reduce(0.0) { $0 + $1.sleepQuality } / Double(monthSessions.count)
                _ = calculateSnoreFrequency(monthSessions)
                
                let monthKey = "Month \(6 - i)"
                monthlyData[monthKey] = monthQuality
            }
        }
        
        return monthlyData
    }
    
    private func generateRecommendations(_ sessions: [SleepSession], sleepQuality: Double, snoreFrequency: Double) -> [String] {
        var recommendations: [String] = []
        
        // Sleep quality recommendations
        if sleepQuality < 0.6 {
            recommendations.append("Consider improving your sleep environment - try reducing noise and light")
            recommendations.append("Maintain a consistent sleep schedule")
        }
        
        // Snore frequency recommendations
        if snoreFrequency > 5.0 {
            recommendations.append("High snore frequency detected - consider consulting a sleep specialist")
            recommendations.append("Try sleeping on your side to reduce snoring")
        }
        
        // Duration recommendations
        let averageDuration = sessions.reduce(0.0) { $0 + $1.duration / 3600 } / Double(sessions.count)
        if averageDuration < 7.0 {
            recommendations.append("Aim for 7-9 hours of sleep per night")
        } else if averageDuration > 9.0 {
            recommendations.append("Consider if you're getting too much sleep - quality over quantity")
        }
        
        // Trend-based recommendations
        if let sleepQualityTrend = sleepInsights?.trends["sleep_quality_trend"], sleepQualityTrend < -0.1 {
            recommendations.append("Your sleep quality has been declining - review your recent habits")
        }
        
        if let snoreTrend = sleepInsights?.trends["snore_frequency_trend"], snoreTrend > 1.0 {
            recommendations.append("Snoring frequency is increasing - consider lifestyle changes")
        }
        
        return recommendations.isEmpty ? ["Keep up the good work! Your sleep patterns look healthy."] : recommendations
    }
}