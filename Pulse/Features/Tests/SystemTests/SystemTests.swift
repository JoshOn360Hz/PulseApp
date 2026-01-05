import UIKit
import Network
import SwiftUI
import Combine

// MARK: - Battery Test
class BatteryTest: BaseDiagnosticTest {
    @Published var level: Float = 0
    @Published var state: UIDevice.BatteryState = .unknown
    @Published var isMonitoring = false
    
    init() {
        super.init(
            id: "battery",
            title: "Battery",
            description: "Check battery level and state",
            category: .systemConnectivity,
            isSupported: true
        )
    }
    
    override func run() async throws {
        status = .running
        startMonitoring()
    }
    
    func startMonitoring() {
        let device = UIDevice.current
        device.isBatteryMonitoringEnabled = true
        
        level = device.batteryLevel
        state = device.batteryState
        
        NotificationCenter.default.addObserver(
            forName: UIDevice.batteryLevelDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.level = device.batteryLevel
        }
        
        NotificationCenter.default.addObserver(
            forName: UIDevice.batteryStateDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.state = device.batteryState
            }
        }
        
        isMonitoring = true
    }
    
    func batteryStateString(_ state: UIDevice.BatteryState) -> String {
        switch state {
        case .unknown: return "Unknown"
        case .unplugged: return "Unplugged"
        case .charging: return "Charging"
        case .full: return "Full"
        @unknown default: return "Unknown"
        }
    }
    
    func confirmSuccess() {
        markPassed(metadata: [
            "level": "\(Int(level * 100))%",
            "state": batteryStateString(state)
        ])
    }
    
    func stopMonitoring() {
        UIDevice.current.isBatteryMonitoringEnabled = false
        NotificationCenter.default.removeObserver(self)
        isMonitoring = false
    }
    
    override func reset() {
        super.reset()
        stopMonitoring()
    }
}

// MARK: - Network Test
class NetworkTest: BaseDiagnosticTest {
    @Published var isConnected = false
    @Published var connectionType: NWInterface.InterfaceType?
    
    private var monitor: NWPathMonitor?
    
    init() {
        super.init(
            id: "network",
            title: "Network",
            description: "Check Wi-Fi/Cellular connectivity",
            category: .systemConnectivity,
            isSupported: true
        )
    }
    
    override func run() async throws {
        status = .running
        startMonitoring()
    }
    
    func startMonitoring() {
        let monitor = NWPathMonitor()
        
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.connectionType = path.availableInterfaces.first?.type
            }
        }
        
        monitor.start(queue: DispatchQueue.global(qos: .background))
        self.monitor = monitor
    }
    
    func confirmSuccess() {
        if isConnected {
            let typeString = connectionType?.description ?? "Unknown"
            markPassed(metadata: ["type": typeString])
        } else {
            markFailed(reason: "No network connection detected")
        }
    }
    
    func stopMonitoring() {
        monitor?.cancel()
        monitor = nil
    }
    
    override func reset() {
        super.reset()
        stopMonitoring()
    }
}

// MARK: - Thermal State Test
class ThermalStateTest: BaseDiagnosticTest {
    @Published var thermalState: ProcessInfo.ThermalState = .nominal
    
    init() {
        super.init(
            id: "thermal",
            title: "Thermal State",
            description: "Check device temperature state",
            category: .systemConnectivity,
            isSupported: true
        )
    }
    
    override func run() async throws {
        status = .running
        thermalState = ProcessInfo.processInfo.thermalState
    }
    
    func confirmSuccess() {
        let stateString = thermalStateString(thermalState)
        markPassed(metadata: ["state": stateString])
    }
    
    func thermalStateString(_ state: ProcessInfo.ThermalState) -> String {
        switch state {
        case .nominal: return "Nominal"
        case .fair: return "Fair"
        case .serious: return "Serious"
        case .critical: return "Critical"
        @unknown default: return "Unknown"
        }
    }
}

extension NWInterface.InterfaceType {
    var description: String {
        switch self {
        case .wifi: return "Wi-Fi"
        case .cellular: return "Cellular"
        case .wiredEthernet: return "Ethernet"
        case .loopback: return "Loopback"
        case .other: return "Other"
        @unknown default: return "Unknown"
        }
    }
}
