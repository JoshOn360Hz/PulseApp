import Foundation
import UIKit

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

struct DeviceInfo: Codable {
    let model: String
    let modelIdentifier: String
    let systemName: String
    let systemVersion: String
    let deviceName: String
    let batteryLevel: Float
    let batteryState: String
    let screenResolution: String
    let screenScale: String
    let totalStorage: String
    let availableStorage: String
    let totalMemory: String
    let processorCount: Int
    let isLowPowerModeEnabled: Bool
    let locale: String
    let timezone: String
    
    init() {
        let device = UIDevice.current
        self.model = device.model
        self.systemName = device.systemName
        self.systemVersion = device.systemVersion
        self.deviceName = device.name
        
        // Model identifier
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        self.modelIdentifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        // Battery info
        device.isBatteryMonitoringEnabled = true
        self.batteryLevel = device.batteryLevel
        
        switch device.batteryState {
        case .unknown: self.batteryState = "Unknown"
        case .unplugged: self.batteryState = "Unplugged"
        case .charging: self.batteryState = "Charging"
        case .full: self.batteryState = "Full"
        @unknown default: self.batteryState = "Unknown"
        }
        
        // Screen info
        let screen = UIScreen.main
        let bounds = screen.bounds
        let scale = screen.scale
        self.screenResolution = "\(Int(bounds.width * scale)) × \(Int(bounds.height * scale))"
        self.screenScale = "\(Int(scale))x"
        
        // Storage info
        if let totalSpace = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())[.systemSize] as? Int64 {
            self.totalStorage = ByteCountFormatter.string(fromByteCount: totalSpace, countStyle: .binary)
        } else {
            self.totalStorage = "Unknown"
        }
        
        if let freeSpace = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())[.systemFreeSize] as? Int64 {
            self.availableStorage = ByteCountFormatter.string(fromByteCount: freeSpace, countStyle: .binary)
        } else {
            self.availableStorage = "Unknown"
        }
        
        // Memory info
        let physicalMemory = ProcessInfo.processInfo.physicalMemory
        self.totalMemory = ByteCountFormatter.string(fromByteCount: Int64(physicalMemory), countStyle: .binary)
        
        // Processor info
        self.processorCount = ProcessInfo.processInfo.processorCount
        
        // Low power mode
        self.isLowPowerModeEnabled = ProcessInfo.processInfo.isLowPowerModeEnabled
        
        // Locale and timezone
        self.locale = Locale.current.identifier
        self.timezone = TimeZone.current.identifier
    }
}
