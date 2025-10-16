//
//  SleepSession.swift
//  open-sleep-tracker
//
//  Created by AI Assistant on 10/16/25.
//

import Foundation
import CoreData

@objc(SleepSession)
public class SleepSession: NSManagedObject {
    
}

extension SleepSession {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SleepSession> {
        return NSFetchRequest<SleepSession>(entityName: "SleepSession")
    }
    
    @NSManaged public var id: UUID
    @NSManaged public var startTime: Date
    @NSManaged public var endTime: Date?
    @NSManaged public var sleepQuality: Double
    @NSManaged public var totalSnoreEvents: Int32
    @NSManaged public var averageSnoreIntensity: Double
    @NSManaged public var heartRateData: Data?
    @NSManaged public var respiratoryRate: Double
    @NSManaged public var isActive: Bool
    @NSManaged public var snoreEvents: NSSet?
    @NSManaged public var healthKitData: Data?
    
    public var duration: TimeInterval {
        guard let endTime = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return endTime.timeIntervalSince(startTime)
    }
    
    public var durationString: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        return String(format: "%d:%02d", hours, minutes)
    }
}

// MARK: Generated accessors for snoreEvents
extension SleepSession {
    
    @objc(addSnoreEventsObject:)
    @NSManaged public func addToSnoreEvents(_ value: SnoreEvent)
    
    @objc(removeSnoreEventsObject:)
    @NSManaged public func removeFromSnoreEvents(_ value: SnoreEvent)
    
    @objc(addSnoreEvents:)
    @NSManaged public func addToSnoreEvents(_ values: NSSet)
    
    @objc(removeSnoreEvents:)
    @NSManaged public func removeFromSnoreEvents(_ values: NSSet)
}

extension SleepSession : Identifiable {
    
}