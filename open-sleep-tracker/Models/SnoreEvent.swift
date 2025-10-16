//
//  SnoreEvent.swift
//  open-sleep-tracker
//
//  Created by AI Assistant on 10/16/25.
//

import Foundation
import CoreData

@objc(SnoreEvent)
public class SnoreEvent: NSManagedObject {
    
}

extension SnoreEvent {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SnoreEvent> {
        return NSFetchRequest<SnoreEvent>(entityName: "SnoreEvent")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var timestamp: Date
    @NSManaged public var intensity: Double
    @NSManaged public var confidence: Double
    @NSManaged public var duration: Double
    @NSManaged public var audioData: Data?
    @NSManaged public var classification: String
    @NSManaged public var sleepSession: SleepSession?
    
    var intensityLevel: SnoreIntensity {
        switch intensity {
        case 0..<0.3:
            return .light
        case 0.3..<0.7:
            return .moderate
        default:
            return .heavy
        }
    }
    
    var isHighConfidence: Bool {
        return confidence > 0.8
    }
}

enum SnoreIntensity: String, CaseIterable {
    case light = "Light"
    case moderate = "Moderate"
    case heavy = "Heavy"
    
    var color: String {
        switch self {
        case .light:
            return "green"
        case .moderate:
            return "orange"
        case .heavy:
            return "red"
        }
    }
}

extension SnoreEvent : Identifiable {
    
}