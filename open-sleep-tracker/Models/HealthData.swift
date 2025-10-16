//
//  HealthData.swift
//  open-sleep-tracker
//
//  Created by AI Assistant on 10/16/25.
//

import Foundation
import HealthKit

struct HealthData: Codable {
    let heartRate: Double?
    let respiratoryRate: Double?
    let sleepStages: [SleepStage]?
    let movementData: [MovementData]?
    let timestamp: Date
}

struct SleepStage: Codable {
    let stage: SleepStageType
    let startTime: Date
    let endTime: Date
    let confidence: Double
}

enum SleepStageType: String, CaseIterable, Codable {
    case awake = "Awake"
    case light = "Light"
    case deep = "Deep"
    case rem = "REM"
    
    var color: String {
        switch self {
        case .awake:
            return "red"
        case .light:
            return "yellow"
        case .deep:
            return "blue"
        case .rem:
            return "purple"
        }
    }
}

struct MovementData: Codable {
    let timestamp: Date
    let intensity: Double
    let type: MovementType
}

enum MovementType: String, CaseIterable, Codable {
    case still = "Still"
    case light = "Light Movement"
    case moderate = "Moderate Movement"
    case heavy = "Heavy Movement"
}

struct SleepInsights: Codable {
    let sleepQuality: Double
    let snoreFrequency: Double
    let correlationWithHealth: [String: Double]
    let recommendations: [String]
    let trends: [String: Double]
}