//
//  SettingsView.swift
//  open-sleep-tracker
//
//  Created by AI Assistant on 10/16/25.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var healthAgent = HealthIntegrationAgent()
    @State private var notificationsEnabled = true
    @State private var snoreThreshold: Double = 0.7
    @State private var autoStartSleep = false
    @State private var showPrivacyPolicy = false
    @State private var showAbout = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Customize your sleep tracking experience")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 20)
                
                // Health Integration
                GlassCardView {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                            Text("Health Integration")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        VStack(spacing: 10) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("HealthKit Access")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text(healthAgent.isAuthorized ? "Connected" : "Not Connected")
                                        .font(.caption)
                                        .foregroundColor(healthAgent.isAuthorized ? .green : .red)
                                }
                                
                                Spacer()
                                
                                if !healthAgent.isAuthorized {
                                    Button("Connect") {
                                        healthAgent.requestHealthKitPermissions()
                                    }
                                    .buttonStyle(GlassButtonStyle(style: .secondary))
                                }
                            }
                            
                            if healthAgent.isAuthorized {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Synced Data:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                        Text("Sleep Analysis")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                        Text("Heart Rate")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .font(.caption)
                                        Text("Respiratory Rate")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }
                
                // Sleep Tracking Settings
                GlassCardView {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.blue)
                            Text("Sleep Tracking")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        VStack(spacing: 15) {
                            // Notifications
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Notifications")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text("Get sleep insights and reminders")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $notificationsEnabled)
                                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                            }
                            
                            Divider()
                                .background(.white.opacity(0.2))
                            
                            // Snore Threshold
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Snore Detection Threshold")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                    
                                    Text("\(Int(snoreThreshold * 100))%")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.blue)
                                }
                                
                                Slider(value: $snoreThreshold, in: 0.1...1.0, step: 0.1)
                                    .accentColor(.blue)
                                
                                Text("Higher values reduce false positives but may miss some snore events")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                                .background(.white.opacity(0.2))
                            
                            // Auto Start Sleep
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Auto Start Sleep Tracking")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text("Automatically start tracking when you go to bed")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $autoStartSleep)
                                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                            }
                        }
                    }
                }
                
                // Privacy & Data
                GlassCardView {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.green)
                            Text("Privacy & Data")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        VStack(spacing: 10) {
                            Button(action: { showPrivacyPolicy = true }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Privacy Policy")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                        
                                        Text("How we protect your data")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Divider()
                                .background(.white.opacity(0.2))
                            
                            Button(action: { }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Export Data")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                        
                                        Text("Download your sleep data")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Divider()
                                .background(.white.opacity(0.2))
                            
                            Button(action: { }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Delete All Data")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.red)
                                        
                                        Text("Permanently remove all data")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
                
                // About
                GlassCardView {
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            Text("About")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        
                        VStack(spacing: 10) {
                            Button(action: { showAbout = true }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("App Information")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                        
                                        Text("Version 1.0.0")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Divider()
                                .background(.white.opacity(0.2))
                            
                            Button(action: { }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Support")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                        
                                        Text("Get help and support")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
    }
}

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Privacy Policy")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)
                    
                    Text("Your privacy is important to us. This app processes all data locally on your device and does not send any personal information to external servers.")
                        .font(.body)
                    
                    Text("Data Collection")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("• Audio data is processed locally for snore detection\n• Sleep patterns are stored locally on your device\n• Health data is only accessed with your explicit permission\n• No data is transmitted to external servers")
                        .font(.body)
                    
                    Text("Data Security")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("• All data is encrypted using Apple's secure storage\n• Health data is protected by HealthKit's security measures\n• Audio data is processed in real-time and not permanently stored")
                        .font(.body)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Open Sleep Tracker")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Version 1.0.0")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("An intelligent sleep tracking app that monitors your sleep patterns and snoring using advanced AI technology. All processing is done locally on your device to ensure your privacy.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    VStack(spacing: 10) {
                        Text("Features:")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("• Real-time snore detection")
                            Text("• Sleep quality analysis")
                            Text("• HealthKit integration")
                            Text("• Privacy-focused design")
                            Text("• Beautiful glass UI")
                        }
                        .font(.body)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.ultraThinMaterial)
                    )
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}