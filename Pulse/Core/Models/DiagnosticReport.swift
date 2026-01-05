import Foundation
import UIKit

// Diagnostic Report
struct DiagnosticReport: Codable {
    let id: UUID
    let timestamp: Date
    let deviceInfo: DeviceInfo
    let results: [TestResult]
    
    var passedTests: [TestResult] {
        results.filter { $0.status == .passed }
    }
    
    var failedTests: [TestResult] {
        results.filter { $0.status == .failed }
    }
    
    var skippedTests: [TestResult] {
        results.filter { $0.status == .skipped }
    }
    
    init(results: [TestResult]) {
        self.id = UUID()
        self.timestamp = Date()
        self.deviceInfo = DeviceInfo()
        self.results = results
    }
}

// Device Info
struct DeviceInfo: Codable {
    let model: String
    let systemName: String
    let systemVersion: String
    let deviceName: String
    let batteryLevel: Float
    let batteryState: String
    
    init() {
        let device = UIDevice.current
        self.model = device.model
        self.systemName = device.systemName
        self.systemVersion = device.systemVersion
        self.deviceName = device.name
        
        device.isBatteryMonitoringEnabled = true
        self.batteryLevel = device.batteryLevel
        
        switch device.batteryState {
        case .unknown: self.batteryState = "Unknown"
        case .unplugged: self.batteryState = "Unplugged"
        case .charging: self.batteryState = "Charging"
        case .full: self.batteryState = "Full"
        @unknown default: self.batteryState = "Unknown"
        }
    }
}
