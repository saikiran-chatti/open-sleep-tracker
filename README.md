# Open Sleep Tracker

A modern iOS sleep tracking application with AI-powered snore detection and comprehensive health integration.

## Features

### 🎯 Core Functionality
- **Real-time Snore Detection**: Advanced Core ML-powered audio classification
- **Sleep Quality Analysis**: Comprehensive sleep pattern analysis with insights
- **HealthKit Integration**: Seamless integration with Apple's health ecosystem
- **Beautiful Glass UI**: Modern, clean interface with glassmorphism design
- **Privacy-First**: All processing done locally on device

### 📊 Analytics & Insights
- Sleep quality scoring and trends
- Snore frequency analysis
- Weekly and monthly pattern tracking
- Personalized recommendations
- Health data correlation analysis

### 🔒 Privacy & Security
- On-device audio processing
- No data transmitted to external servers
- End-to-end encrypted CloudKit sync
- HIPAA-compliant health data handling

## Architecture

The app is built using a modular AI agent architecture:

### AI Agents
1. **Audio Classification Agent**: Real-time snore detection using Core ML
2. **Sleep Pattern Analysis Agent**: Advanced sleep quality analysis
3. **Health Integration Agent**: HealthKit data synchronization
4. **Intelligent Notification Agent**: Smart, context-aware notifications
5. **Data Synchronization Agent**: CloudKit data management
6. **StandBy Mode Intelligence Agent**: Always-on display features

### Technical Stack
- **Framework**: SwiftUI + Combine
- **Data**: Core Data + CloudKit
- **ML**: Core ML + SoundAnalysis
- **Health**: HealthKit
- **UI**: Glassmorphism design with custom components

## Requirements

- iOS 26.0+
- Xcode 26.0+
- Swift 5.0+
- iPhone, iPad, or Apple Vision Pro

## Installation

1. Clone the repository:
```bash
git clone https://github.com/your-username/open-sleep-tracker.git
cd open-sleep-tracker
```

2. Open the project in Xcode:
```bash
open open-sleep-tracker.xcodeproj
```

3. Build and run on your device or simulator

## Usage

### Getting Started
1. Launch the app and grant microphone permissions
2. Connect to HealthKit for comprehensive health data
3. Start your first sleep session
4. View insights and analytics in the dashboard

### Sleep Tracking
- Tap "Start Sleep Session" to begin monitoring
- The app will detect snoring patterns in real-time
- View live snore intensity levels
- Stop the session when you wake up

### Analytics
- View sleep quality trends over time
- Analyze snore frequency patterns
- Get personalized recommendations
- Track correlations with health data

## Permissions

The app requires the following permissions:

- **Microphone**: For snore detection and audio analysis
- **HealthKit**: For sleep data, heart rate, and respiratory rate
- **CloudKit**: For data synchronization across devices

## Development

### Project Structure
```
open-sleep-tracker/
├── Agents/           # AI agent implementations
├── Models/           # Core Data models and data structures
├── Views/            # SwiftUI view components
├── ViewModels/       # View model classes
├── Utils/            # Utility functions
└── Extensions/       # Swift extensions
```

### Building
```bash
# Build for simulator
xcodebuild -project open-sleep-tracker.xcodeproj -scheme open-sleep-tracker -destination 'platform=iOS Simulator,name=iPhone 17' build

# Build for device
xcodebuild -project open-sleep-tracker.xcodeproj -scheme open-sleep-tracker -destination 'generic/platform=iOS' build
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Apple's Core ML and SoundAnalysis frameworks
- HealthKit for health data integration
- SwiftUI for the modern UI framework
- The open-source community for inspiration

## Support

For support, please open an issue on GitHub or contact the development team.

---

**Note**: This app is designed for health monitoring purposes and should not replace professional medical advice. Always consult with healthcare professionals for sleep-related concerns.