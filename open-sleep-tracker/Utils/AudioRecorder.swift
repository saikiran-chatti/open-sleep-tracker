//
//  AudioRecorder.swift
//  open-sleep-tracker
//
//  Created by Jay Chatti on 10/16/25.
//  Enhanced with encryption and playback by AI Agent on 11/22/25.
//

import Foundation
import AVFoundation
import Combine
import CryptoKit

class AudioRecorder: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var audioLevel: Float = 0.0
    @Published var recordings: [AudioRecording] = []
    @Published var currentRecording: AudioRecording?
    @Published var isPlaying = false
    @Published var currentlyPlayingId: UUID?

    private var audioEngine = AVAudioEngine()
    private var audioFile: AVAudioFile?
    private var recordingTimer: Timer?
    private var levelTimer: Timer?
    private var audioPlayer: AVAudioPlayer?

    // Secure storage in app's private container
    private let documentsPath: URL
    private let metadataPath: URL

    // Encryption key stored in Keychain
    private let encryptionKeyTag = "com.opensleeptracker.audioEncryptionKey"

    override init() {
        // Use app's private documents directory (not accessible to other apps)
        documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("SecureRecordings", isDirectory: true)
        metadataPath = documentsPath.appendingPathComponent("metadata.json")

        super.init()

        // Create secure directory if needed
        createSecureDirectory()
        setupAudioSession()
        loadExistingRecordings()
    }

    private func createSecureDirectory() {
        do {
            if !FileManager.default.fileExists(atPath: documentsPath.path) {
                try FileManager.default.createDirectory(at: documentsPath, withIntermediateDirectories: true)

                // Set file protection - encrypts files when device is locked
                try FileManager.default.setAttributes(
                    [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
                    ofItemAtPath: documentsPath.path
                )
            }
        } catch {
            print("Failed to create secure directory: \(error)")
        }
    }

    private func setupAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowBluetoothHFP])
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    // MARK: - Encryption Key Management

    private func getOrCreateEncryptionKey() -> SymmetricKey {
        // Try to load existing key from Keychain
        if let keyData = loadKeyFromKeychain() {
            return SymmetricKey(data: keyData)
        }

        // Generate new key and store in Keychain
        let newKey = SymmetricKey(size: .bits256)
        let keyData = newKey.withUnsafeBytes { Data($0) }
        saveKeyToKeychain(keyData)

        return newKey
    }

    private func loadKeyFromKeychain() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: encryptionKeyTag,
            kSecReturnData as String: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecSuccess {
            return result as? Data
        }
        return nil
    }

    private func saveKeyToKeychain(_ keyData: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: encryptionKeyTag,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        // Delete existing key if present
        SecItemDelete(query as CFDictionary)

        // Add new key
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Failed to save encryption key to Keychain: \(status)")
        }
    }

    // MARK: - Encryption/Decryption

    private func encryptData(_ data: Data) throws -> Data {
        let key = getOrCreateEncryptionKey()
        let sealedBox = try AES.GCM.seal(data, using: key)

        guard let combined = sealedBox.combined else {
            throw EncryptionError.encryptionFailed
        }
        return combined
    }

    private func decryptData(_ encryptedData: Data) throws -> Data {
        let key = getOrCreateEncryptionKey()
        let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
        return try AES.GCM.open(sealedBox, using: key)
    }

    enum EncryptionError: Error {
        case encryptionFailed
        case decryptionFailed
    }

    // MARK: - Recording

    func startRecording() {
        guard !isRecording else { return }

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
            // Create temporary unencrypted file for recording
            let fileName = "recording_\(Date().timeIntervalSince1970).m4a"
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            let finalURL = documentsPath.appendingPathComponent(fileName + ".encrypted")

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            audioFile = try AVAudioFile(forWriting: tempURL, settings: settings)

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
                fileURL: finalURL,
                tempURL: tempURL,
                startTime: Date(),
                duration: 0,
                audioLevel: 0.0,
                isEncrypted: true
            )

            isRecording = true
            recordingDuration = 0

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

        // Encrypt and save the recording
        if var recording = currentRecording {
            recording.duration = recordingDuration
            recording.endTime = Date()

            // Calculate average audio level during recording
            recording.audioLevel = audioLevel

            // Encrypt the audio file
            if let tempURL = recording.tempURL {
                do {
                    let audioData = try Data(contentsOf: tempURL)
                    let encryptedData = try encryptData(audioData)
                    try encryptedData.write(to: recording.fileURL)

                    // Delete temporary unencrypted file
                    try FileManager.default.removeItem(at: tempURL)

                    recordings.append(recording)
                    saveRecordingsMetadata()
                } catch {
                    print("Failed to encrypt recording: \(error)")
                    // Fall back to saving unencrypted
                    do {
                        try FileManager.default.moveItem(at: tempURL, to: recording.fileURL)
                        var unencryptedRecording = recording
                        unencryptedRecording.isEncrypted = false
                        recordings.append(unencryptedRecording)
                        saveRecordingsMetadata()
                    } catch {
                        print("Failed to save recording: \(error)")
                    }
                }
            }
        }

        currentRecording = nil
        isRecording = false

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
            let normalizedPower = max(0.0, min(1.0, (avgPower + 60) / 60))

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

    // MARK: - Playback

    func playRecording(_ recording: AudioRecording) {
        // Stop any current playback
        stopPlayback()

        do {
            // Setup audio session for playback
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)

            if recording.isEncrypted {
                // Decrypt the audio file and write to temp for playback
                let encryptedData = try Data(contentsOf: recording.fileURL)
                let audioData = try decryptData(encryptedData)

                // Write decrypted data to temp file for playback
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("playback_temp.m4a")
                try audioData.write(to: tempURL)

                // Create player from temp file
                audioPlayer = try AVAudioPlayer(contentsOf: tempURL)
            } else {
                audioPlayer = try AVAudioPlayer(contentsOf: recording.fileURL)
            }

            audioPlayer?.delegate = self
            audioPlayer?.volume = 1.0
            audioPlayer?.prepareToPlay()

            let success = audioPlayer?.play() ?? false
            print("Playback started: \(success), duration: \(audioPlayer?.duration ?? 0)")

            isPlaying = true
            currentlyPlayingId = recording.id

        } catch {
            print("Failed to play recording: \(error)")
            isPlaying = false
            currentlyPlayingId = nil
        }
    }

    func stopPlayback() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentlyPlayingId = nil
    }

    func togglePlayback(_ recording: AudioRecording) {
        if currentlyPlayingId == recording.id && isPlaying {
            stopPlayback()
        } else {
            playRecording(recording)
        }
    }

    // MARK: - Delete

    func deleteRecording(_ recording: AudioRecording) {
        // Stop playback if this recording is playing
        if currentlyPlayingId == recording.id {
            stopPlayback()
        }

        // Delete encrypted file
        try? FileManager.default.removeItem(at: recording.fileURL)

        // Remove from array
        recordings.removeAll { $0.id == recording.id }
        saveRecordingsMetadata()
    }

    // MARK: - Metadata Persistence

    private func loadExistingRecordings() {
        // Load metadata from JSON file
        guard FileManager.default.fileExists(atPath: metadataPath.path) else {
            // No existing metadata, scan directory for orphaned files
            scanForOrphanedRecordings()
            return
        }

        do {
            let data = try Data(contentsOf: metadataPath)
            let decoder = JSONDecoder()
            recordings = try decoder.decode([AudioRecording].self, from: data)

            // Verify files still exist
            recordings = recordings.filter { recording in
                FileManager.default.fileExists(atPath: recording.fileURL.path)
            }

        } catch {
            print("Failed to load recordings metadata: \(error)")
            scanForOrphanedRecordings()
        }
    }

    private func scanForOrphanedRecordings() {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: documentsPath,
                includingPropertiesForKeys: [.creationDateKey, .fileSizeKey],
                options: .skipsHiddenFiles
            )

            recordings = fileURLs
                .filter { $0.pathExtension == "encrypted" || $0.pathExtension == "m4a" }
                .compactMap { url in
                    let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
                    let creationDate = attributes?[.creationDate] as? Date ?? Date()

                    // Calculate duration by decrypting and reading the audio file
                    let duration = calculateDuration(for: url, isEncrypted: url.pathExtension == "encrypted")

                    return AudioRecording(
                        id: UUID(),
                        fileName: url.deletingPathExtension().lastPathComponent,
                        fileURL: url,
                        tempURL: nil,
                        startTime: creationDate,
                        duration: duration,
                        audioLevel: 0.3, // Default moderate level for orphaned files
                        isEncrypted: url.pathExtension == "encrypted"
                    )
                }
                .sorted { $0.startTime > $1.startTime }

            saveRecordingsMetadata()
        } catch {
            print("Failed to scan for recordings: \(error)")
        }
    }

    private func calculateDuration(for url: URL, isEncrypted: Bool) -> TimeInterval {
        do {
            let audioData: Data

            if isEncrypted {
                let encryptedData = try Data(contentsOf: url)
                audioData = try decryptData(encryptedData)
            } else {
                audioData = try Data(contentsOf: url)
            }

            // Write to temp file to get duration
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp_duration.m4a")
            try audioData.write(to: tempURL)

            let asset = AVURLAsset(url: tempURL)
            let duration = CMTimeGetSeconds(asset.duration)

            // Clean up temp file
            try? FileManager.default.removeItem(at: tempURL)

            return duration.isNaN ? 0 : duration

        } catch {
            print("Failed to calculate duration: \(error)")
            return 0
        }
    }

    private func saveRecordingsMetadata() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(recordings)
            try data.write(to: metadataPath)

            // Set file protection on metadata
            try FileManager.default.setAttributes(
                [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
                ofItemAtPath: metadataPath.path
            )
        } catch {
            print("Failed to save recordings metadata: \(error)")
        }
    }

    // MARK: - Status

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

    func getSecurityStatus() -> String {
        let hasKey = loadKeyFromKeychain() != nil
        return hasKey ? "Encrypted with AES-256-GCM" : "Encryption key not initialized"
    }
}

// MARK: - AVAudioPlayerDelegate

extension AudioRecorder: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentlyPlayingId = nil
        }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio player decode error: \(String(describing: error))")
        DispatchQueue.main.async {
            self.isPlaying = false
            self.currentlyPlayingId = nil
        }
    }
}

// MARK: - Audio Recording Model

struct AudioRecording: Identifiable, Codable {
    let id: UUID
    let fileName: String
    let fileURL: URL
    var tempURL: URL?
    let startTime: Date
    var endTime: Date?
    var duration: TimeInterval
    var audioLevel: Float
    var isEncrypted: Bool

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

    var securityBadge: String {
        isEncrypted ? "🔒 Encrypted" : "⚠️ Unencrypted"
    }
}
