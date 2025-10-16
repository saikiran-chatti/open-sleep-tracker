//
//  HealthIntegrationAgent.swift
//  open-sleep-tracker
//
//  Created by AI Assistant on 10/16/25.
//

import Foundation
import HealthKit
import Combine

@MainActor
class HealthIntegrationAgent: NSObject, ObservableObject {
    @Published var isAuthorized = false
    @Published var healthData: HealthData?
    @Published var sleepStages: [SleepStage] = []
    @Published var heartRateData: [Double] = []
    @Published var respiratoryRateData: [Double] = []
    
    private let healthStore = HKHealthStore()
    private var cancellables = Set<AnyCancellable>()
    
    // Health data types we need
    private let healthDataTypes: Set<HKObjectType> = [
        HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
        HKObjectType.quantityType(forIdentifier: .heartRate)!,
        HKObjectType.quantityType(forIdentifier: .respiratoryRate)!,
        HKObjectType.quantityType(forIdentifier: .bodyMass)!,
        HKObjectType.quantityType(forIdentifier: .height)!
    ]
    
    override init() {
        super.init()
        checkHealthKitAvailability()
    }
    
    private func checkHealthKitAvailability() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit is not available on this device")
            return
        }
        
        requestHealthKitPermissions()
    }
    
    func requestHealthKitPermissions() {
        healthStore.requestAuthorization(toShare: nil, read: healthDataTypes) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isAuthorized = success
                if let error = error {
                    print("HealthKit authorization failed: \(error)")
                }
            }
        }
    }
    
    func fetchSleepData(for date: Date) {
        guard isAuthorized else { return }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { [weak self] _, samples, error in
            guard let samples = samples as? [HKCategorySample], error == nil else {
                print("Failed to fetch sleep data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self?.processSleepSamples(samples)
            }
        }
        
        healthStore.execute(query)
    }
    
    private func processSleepSamples(_ samples: [HKCategorySample]) {
        var stages: [SleepStage] = []
        
        for sample in samples {
            let stage = SleepStage(
                stage: mapSleepStage(sample.value),
                startTime: sample.startDate,
                endTime: sample.endDate,
                confidence: 1.0 // HealthKit doesn't provide confidence scores
            )
            stages.append(stage)
        }
        
        sleepStages = stages.sorted { $0.startTime < $1.startTime }
    }
    
    private func mapSleepStage(_ value: Int) -> SleepStageType {
        switch value {
        case HKCategoryValueSleepAnalysis.inBed.rawValue:
            return .awake
        case HKCategoryValueSleepAnalysis.asleepCore.rawValue:
            return .light
        case HKCategoryValueSleepAnalysis.asleepDeep.rawValue:
            return .deep
        case HKCategoryValueSleepAnalysis.asleepREM.rawValue:
            return .rem
        default:
            return .awake
        }
    }
    
    func fetchHeartRateData(for date: Date) {
        guard isAuthorized else { return }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate)!
        let query = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { [weak self] _, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                print("Failed to fetch heart rate data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self?.processHeartRateSamples(samples)
            }
        }
        
        healthStore.execute(query)
    }
    
    private func processHeartRateSamples(_ samples: [HKQuantitySample]) {
        let heartRateUnit = HKUnit(from: "count/min")
        heartRateData = samples.map { $0.quantity.doubleValue(for: heartRateUnit) }
    }
    
    func fetchRespiratoryRateData(for date: Date) {
        guard isAuthorized else { return }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictStartDate)
        
        let respiratoryRateType = HKObjectType.quantityType(forIdentifier: .respiratoryRate)!
        let query = HKSampleQuery(sampleType: respiratoryRateType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) { [weak self] _, samples, error in
            guard let samples = samples as? [HKQuantitySample], error == nil else {
                print("Failed to fetch respiratory rate data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self?.processRespiratoryRateSamples(samples)
            }
        }
        
        healthStore.execute(query)
    }
    
    private func processRespiratoryRateSamples(_ samples: [HKQuantitySample]) {
        let respiratoryRateUnit = HKUnit(from: "count/min")
        respiratoryRateData = samples.map { $0.quantity.doubleValue(for: respiratoryRateUnit) }
    }
    
    func fetchAllHealthData(for date: Date) {
        fetchSleepData(for: date)
        fetchHeartRateData(for: date)
        fetchRespiratoryRateData(for: date)
    }
    
    func createHealthData() -> HealthData {
        return HealthData(
            heartRate: heartRateData.isEmpty ? nil : heartRateData.reduce(0, +) / Double(heartRateData.count),
            respiratoryRate: respiratoryRateData.isEmpty ? nil : respiratoryRateData.reduce(0, +) / Double(respiratoryRateData.count),
            sleepStages: sleepStages.isEmpty ? nil : sleepStages,
            movementData: nil, // This would be implemented with motion data
            timestamp: Date()
        )
    }
    
    func saveHealthDataToSleepSession(_ sleepSession: SleepSession) {
        let healthData = createHealthData()
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(healthData)
            sleepSession.healthKitData = data
            sleepSession.heartRateData = heartRateData.isEmpty ? nil : try JSONEncoder().encode(heartRateData)
            sleepSession.respiratoryRate = healthData.respiratoryRate ?? 0.0
            
            CoreDataStack.shared.save()
        } catch {
            print("Failed to save health data: \(error)")
        }
    }
}