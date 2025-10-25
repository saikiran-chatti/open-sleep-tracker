//
//  AudioRecorder.swift
//  open-sleep-tracker
//
//  Created by Jay Chatti on 10/16/25.
//

import Foundation
import AVFoundation
import Combine

class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var audioLevel: Float = 0.0
    @Published var recordings: [AudioRecording] = []
    @Published var currentRecording: AudioRecording?
    
    private var audioEngine = AVAudioEngine()
    private var audioFile: AVAudioFile?
    private var recordingTimer: Timer?
    private var levelTimer: Timer?
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    override init() {
        super.init()
        setupAudioSession()
        loadExistingRecordings()
    }
    
    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: [.allowBluetoothHFP, .allowBluetoothA2DP])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func startRecording() {
        guard !isRecording else { return }
        
        // Check microphone permission first
        checkMicrophonePermission { [weak self] granted in
            guard granted else {
                print("Microphone permission denied")
                return
            }
            
            DispatchQueue.main.async {
                self?.performRecording()
            }
        }
    }
    
    private func checkMicrophonePermission(completion: @escaping (Bool) -> Void) {
        let audioSession = AVAudioSession.sharedInstance()
        
        switch audioSession.recordPermission {
        case .granted:
            completion(true)
        case .denied:
            completion(false)
        case .undetermined:
            audioSession.requestRecordPermission { granted in
                completion(granted)
            }
        @unknown default:
            completion(false)
        }
    }
    
    private func performRecording() {
        do {
            // Create audio file
            let fileName = "recording_\(Date().timeIntervalSince1970).m4a"
            let fileURL = documentsPath.appendingPathComponent(fileName)
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioFile = try AVAudioFile(forWriting: fileURL, settings: settings)
            
            // Setup audio engine
            let inputNode = audioEngine.inputNode
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] (buffer: AVAudioPCMBuffer, _: AVAudioTime) in
                self?.processAudioBuffer(buffer)
            }
            
            try audioEngine.start()
            
            // Create recording object
            currentRecording = AudioRecording(
                id: UUID(),
                fileName: fileName,
                fileURL: fileURL,
                startTime: Date(),
                duration: 0,
                audioLevel: 0.0
            )
            
            isRecording = true
            recordingDuration = 0
            
            // Start timers
            startRecordingTimer()
            startLevelTimer()
            
        } catch {
            print("Failed to start recording: \(error)")
        }
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        // Update recording with final duration
        if var recording = currentRecording {
            recording.duration = recordingDuration
            recording.endTime = Date()
            recordings.append(recording)
            saveRecordings()
        }
        
        currentRecording = nil
        isRecording = false
        
        // Stop timers
        recordingTimer?.invalidate()
        levelTimer?.invalidate()
        recordingTimer = nil
        levelTimer = nil
        
        recordingDuration = 0
        audioLevel = 0.0
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let audioFile = audioFile else { return }
        
        do {
            try audioFile.write(from: buffer)
        } catch {
            print("Failed to write audio buffer: \(error)")
            // Stop recording if we can't write to file
            DispatchQueue.main.async {
                self.stopRecording()
            }
            return
        }
        
        // Calculate audio level
        if let channelData = buffer.floatChannelData {
            let channelDataValue = channelData.pointee
            let channelDataValueArray = stride(from: 0, to: Int(buffer.frameLength), by: buffer.stride).map { channelDataValue[$0] }
            
            let rms = sqrt(channelDataValueArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
            let avgPower = 20 * log10(rms)
            let normalizedPower = max(0.0, min(1.0, (avgPower + 60) / 60)) // Normalize to 0-1 range
            
            DispatchQueue.main.async {
                self.audioLevel = normalizedPower
            }
        }
    }
    
    private func startRecordingTimer() {
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.recordingDuration += 0.1
            }
        }
    }
    
    private func startLevelTimer() {
        levelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            // Audio level is updated in processAudioBuffer
        }
    }
    
    func deleteRecording(_ recording: AudioRecording) {
        // Delete file
        try? FileManager.default.removeItem(at: recording.fileURL)
        
        // Remove from array
        recordings.removeAll { $0.id == recording.id }
        saveRecordings()
    }
    
    func playRecording(_ recording: AudioRecording) {
        // This would implement audio playback
        // For now, just print the file path
        print("Playing recording: \(recording.fileName)")
    }
    
    func isAudioRecordingWorking() -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        return audioSession.recordPermission == .granted && audioEngine.isRunning
    }
    
    func getRecordingStatus() -> String {
        if !isRecording {
            return "Not recording"
        }
        
        if audioEngine.isRunning {
            return "Recording active - \(String(format: "%.1f", recordingDuration))s"
        } else {
            return "Recording stopped"
        }
    }
    
    func testAudioRecording() {
        print("Testing audio recording...")
        print("Microphone permission: \(AVAudioSession.sharedInstance().recordPermission.rawValue)")
        print("Audio engine running: \(audioEngine.isRunning)")
        print("Current recording: \(isRecording)")
        print("Recordings count: \(recordings.count)")
        
        // Test a short recording
        startRecording()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.stopRecording()
            print("Test recording completed. New recordings count: \(self.recordings.count)")
        }
    }
    
    private func loadExistingRecordings() {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: documentsPath,
                includingPropertiesForKeys: [.creationDateKey],
                options: .skipsHiddenFiles
            )
            
            recordings = fileURLs
                .filter { $0.pathExtension == "m4a" }
                .map { url in
                    let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
                    let creationDate = attributes?[.creationDate] as? Date ?? Date()
                    
                    return AudioRecording(
                        id: UUID(),
                        fileName: url.lastPathComponent,
                        fileURL: url,
                        startTime: creationDate,
                        duration: 0, // Would need to calculate actual duration
                        audioLevel: 0.0
                    )
                }
                .sorted { $0.startTime > $1.startTime }
        } catch {
            print("Failed to load recordings: \(error)")
        }
    }
    
    private func saveRecordings() {
        // In a real app, you might save metadata to Core Data or UserDefaults
        // For now, we'll rely on file system storage
    }
}

// MARK: - Audio Recording Model
struct AudioRecording: Identifiable, Codable {
    let id: UUID
    let fileName: String
    let fileURL: URL
    let startTime: Date
    var endTime: Date?
    var duration: TimeInterval
    var audioLevel: Float
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }
    
    var fileSize: String {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let size = attributes[.size] as? Int64 {
                return ByteCountFormatter.string(fromByteCount: size, countStyle: .file)
            }
        } catch {
            print("Failed to get file size: \(error)")
        }
        return "Unknown"
    }
}