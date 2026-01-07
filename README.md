# Pulse

**Pulse** is a comprehensive iOS diagnostic application that enables users to thoroughly test and verify the functionality of various hardware and software components on their iPhone or iPad.

## Features

Pulse provides an extensive suite of diagnostic tests to ensure your device is functioning optimally:

### Hardware Tests
- **Camera Test** - Verify front and rear camera functionality
- **Speaker Test** - Test audio output quality
- **Microphone Test** - Validate audio input and recording
- **Haptics Test** - Check haptic feedback and vibration
- **Touchscreen Test** - Verify screen responsiveness and accuracy
- **Multi-Touch Test** - Test multi-touch gesture recognition
- **Dead Pixel Test** - Detect dead or stuck pixels on the display
- **Power Button Test** - Verify power button functionality
- **Volume Button Test** - Test volume up/down buttons

### Connectivity & Sensors
- **GPS Test** - Validate location services and GPS accuracy
- **Bluetooth Test** - Check Bluetooth connectivity
- **Sensor Tests** - Test accelerometer, gyroscope, and other sensors
- **Biometric Test** - Verify Face ID or Touch ID functionality

### Reports
- **Diagnostic Reports** - Generate detailed test reports
- **Report Export** - Export diagnostic results for sharing or reference

## Architecture

Pulse is built using SwiftUI and follows a modular, feature-based architecture:

```
Pulse/
├── Core/
│   ├── Models/           # Data models for diagnostic tests and reports
│   └── Services/         # Core business logic and services
├── Features/
│   ├── Onboarding/       # First-time user experience
│   ├── Scenes/           # Main app screens (Home, Test, Report)
│   └── Tests/            # Individual diagnostic test modules
└── Assets.xcassets/      # App icons, images, and visual assets
```

### Key Components

- **DiagnosticEngine** - Core service that orchestrates test execution
- **ReportExporter** - Handles generation and export of diagnostic reports
- **DiagnosticTest** - Protocol defining test behavior
- **DiagnosticReport** - Model representing test results

## Requirements

- iOS 16.0+
- Xcode 14.0+
- Swift 5.7+

## Features in Detail

### Test Execution
Each diagnostic test is self-contained and provides:
- Clear instructions for the user
- Real-time feedback during test execution
- Pass/fail results with detailed information
- Visual and haptic feedback

### Report Generation
The diagnostic engine compiles results from all executed tests into a comprehensive report that can be:
- Viewed within the app
- Exported as a shareable document
- Used for warranty claims or technical support

## Privacy

Pulse respects user privacy:
- All diagnostic tests run locally on the device
- No data is transmitted to external servers
- Camera, microphone, and location permissions are requested only when needed
- Users have full control over which tests to run

