//
//  AudioClassificationAgent.swift
//  open-sleep-tracker
//
//  Created by AI Assistant on 10/16/25.
//

import Foundation
import AVFoundation
import SoundAnalysis
import CoreML
import Combine
import CoreData

@MainActor
class AudioClassificationAgent: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var currentSnoreLevel: Double = 0.0
    @Published var lastSnoreEvent: SnoreEvent?
    @Published var recordingDuration: TimeInterval = 0
    
    private var audioEngine: AVAudioEngine?
    private var soundAnalyzer: SNAudioStreamAnalyzer?
    private var classificationRequest: SNClassifySoundRequest?
    private var coreMLModel: MLModel?
    
    private var recordingStartTime: Date?
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // Audio processing parameters
    private let sampleRate: Double = 44100.0
    private let bufferSize: AVAudioFrameCount = 1024
    private let confidenceThreshold: Double = 0.7
    
    override init() {
        super.init()
        setupAudioEngine()
        loadCoreMLModel()
    }
    
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        
        guard let audioEngine = audioEngine else { return }
        
        let inputNode = audioEngine.inputNode
        let inputFormat = inputNode.outputFormat(forBus: 0)
        
        // Configure audio session
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: [.allowBluetoothHFP])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
        
        // Install tap on input node
        inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: inputFormat) { [weak self] buffer, _ in
            self?.processAudioBuffer(buffer)
        }
    }
    
    private func loadCoreMLModel() {
        // For now, we'll use a placeholder model
        // In production, this would load a trained Core ML model
        setupSoundAnalyzer()
    }
    
    private func setupSoundAnalyzer() {
        guard let audioEngine = audioEngine else { return }
        
        soundAnalyzer = SNAudioStreamAnalyzer(format: audioEngine.inputNode.outputFormat(forBus: 0))
        
        // Create classification request
        do {
            classificationRequest = try SNClassifySoundRequest(mlModel: createPlaceholderModel())
            classificationRequest?.windowDuration = CMTime(value: 1, timescale: 10) // 100ms windows
            classificationRequest?.overlapFactor = 0.5
            
            try soundAnalyzer?.add(classificationRequest!, withObserver: self)
        } catch {
            print("Failed to setup sound analyzer: \(error)")
        }
    }
    
    private func createPlaceholderModel() -> MLModel {
        // This is a placeholder - in production you'd use your trained model
        // For now, we'll create a simple model that returns random classifications
        // In a real implementation, you would load a trained Core ML model
        fatalError("Placeholder model not implemented - use a real Core ML model")
    }
    
    func startRecording() {
        guard !isRecording else { return }
        
        do {
            try audioEngine?.start()
            isRecording = true
            recordingStartTime = Date()
            startTimer()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        audioEngine?.stop()
        isRecording = false
        recordingStartTime = nil
        stopTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, let startTime = self.recordingStartTime else { return }
                self.recordingDuration = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        recordingDuration = 0
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        // This is where we would process the audio buffer
        // For now, we'll simulate snore detection
        simulateSnoreDetection()
    }
    
    private func simulateSnoreDetection() {
        // Simulate snore detection with random values
        // In production, this would use the actual ML model
        let randomValue = Double.random(in: 0...1)
        
        if randomValue > 0.8 {
            let confidence = Double.random(in: 0.7...1.0)
            let snoreEvent = createSnoreEvent(intensity: randomValue, confidence: confidence)
            lastSnoreEvent = snoreEvent
            currentSnoreLevel = randomValue
        }
    }
    
    private func createSnoreEvent(intensity: Double, confidence: Double) -> SnoreEvent {
        let context = CoreDataStack.shared.viewContext
        let snoreEvent = SnoreEvent(context: context)
        
        snoreEvent.id = UUID()
        snoreEvent.timestamp = Date()
        snoreEvent.intensity = intensity
        snoreEvent.confidence = confidence
        snoreEvent.duration = Double.random(in: 0.5...3.0)
        snoreEvent.classification = "snore"
        
        return snoreEvent
    }
    
    deinit {
        Task { @MainActor in
            stopRecording()
        }
    }
}

// MARK: - SNResultsObserving
extension AudioClassificationAgent: SNResultsObserving {
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let classificationResult = result as? SNClassificationResult else { return }
        
        // Process classification results
        for classification in classificationResult.classifications {
            if classification.identifier == "snore" && classification.confidence > confidenceThreshold {
                let snoreEvent = createSnoreEvent(
                    intensity: Double(classification.confidence),
                    confidence: classification.confidence
                )
                
                DispatchQueue.main.async {
                    self.lastSnoreEvent = snoreEvent
                    self.currentSnoreLevel = Double(classification.confidence)
                }
            }
        }
    }
    
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("Sound analysis failed: \(error)")
    }
    
    func requestDidComplete(_ request: SNRequest) {
        print("Sound analysis completed")
    }
}