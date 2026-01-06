import CoreMotion
import SwiftUI
import Combine

// Accelerometer Test
class AccelerometerTest: BaseDiagnosticTest {
    @Published var x: Double = 0
    @Published var y: Double = 0
    @Published var z: Double = 0
    @Published var isMonitoring = false
    
    private let motionManager = CMMotionManager()
    private var significantMovementDetected = false
    
    init() {
        super.init(
            id: "accelerometer",
            title: "Accelerometer",
            description: "Move device to see XYZ changes",
            category: .sensors,
            isSupported: CMMotionManager().isAccelerometerAvailable
        )
    }
    
    override func run() async throws {
        status = .running
        startMonitoring()
    }
    
    func startMonitoring() {
        guard motionManager.isAccelerometerAvailable else { return }
        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data else { return }
            
            self.x = data.acceleration.x
            self.y = data.acceleration.y
            self.z = data.acceleration.z
            
            let magnitude = sqrt(pow(data.acceleration.x, 2) + pow(data.acceleration.y, 2) + pow(data.acceleration.z, 2))
            if magnitude > 1.5 {
                self.significantMovementDetected = true
            }
        }
        
        isMonitoring = true
    }
    
    func confirmSuccess() {
        markPassed(metadata: [
            "x": String(format: "%.2f", x),
            "y": String(format: "%.2f", y),
            "z": String(format: "%.2f", z)
        ])
    }
    
    func stopMonitoring() {
        motionManager.stopAccelerometerUpdates()
        isMonitoring = false
    }
    
    override func reset() {
        super.reset()
        stopMonitoring()
        x = 0
        y = 0
        z = 0
        significantMovementDetected = false
    }
}

// MARK: - Gyroscope Test
class GyroscopeTest: BaseDiagnosticTest {
    @Published var pitch: Double = 0
    @Published var roll: Double = 0
    @Published var yaw: Double = 0
    @Published var isMonitoring = false
    
    private let motionManager = CMMotionManager()
    
    init() {
        super.init(
            id: "gyroscope",
            title: "Gyroscope",
            description: "Rotate device to track orientation",
            category: .sensors,
            isSupported: CMMotionManager().isGyroAvailable
        )
    }
    
    override func run() async throws {
        status = .running
        startMonitoring()
    }
    
    func startMonitoring() {
        guard motionManager.isGyroAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else { return }
            
            self.pitch = motion.attitude.pitch * 180 / .pi
            self.roll = motion.attitude.roll * 180 / .pi
            self.yaw = motion.attitude.yaw * 180 / .pi
        }
        
        isMonitoring = true
    }
    
    func confirmSuccess() {
        markPassed(metadata: [
            "pitch": String(format: "%.1f°", pitch),
            "roll": String(format: "%.1f°", roll),
            "yaw": String(format: "%.1f°", yaw)
        ])
    }
    
    func stopMonitoring() {
        motionManager.stopDeviceMotionUpdates()
        isMonitoring = false
    }
    
    override func reset() {
        super.reset()
        stopMonitoring()
        pitch = 0
        roll = 0
        yaw = 0
    }
}

// MARK: - Magnetometer Test
class MagnetometerTest: BaseDiagnosticTest {
    @Published var heading: Double = 0
    @Published var accuracy: Double = 0
    @Published var isMonitoring = false
    
    private let motionManager = CMMotionManager()
    
    init() {
        super.init(
            id: "magnetometer",
            title: "Compass",
            description: "Rotate to track heading changes",
            category: .sensors,
            isSupported: CMMotionManager().isMagnetometerAvailable
        )
    }
    
    override func run() async throws {
        status = .running
        startMonitoring()
    }
    
    func startMonitoring() {
        guard motionManager.isMagnetometerAvailable else { return }
        
        motionManager.deviceMotionUpdateInterval = 0.1
        motionManager.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: .main) { [weak self] motion, error in
            guard let self = self, let motion = motion else { return }
            
            let magneticHeading = motion.heading
            self.heading = magneticHeading >= 0 ? magneticHeading : magneticHeading + 360
            self.accuracy = Double(motion.magneticField.accuracy.rawValue)
        }
        
        isMonitoring = true
    }
    
    func confirmSuccess() {
        markPassed(metadata: [
            "heading": String(format: "%.1f°", heading)
        ])
    }
    
    func stopMonitoring() {
        motionManager.stopDeviceMotionUpdates()
        isMonitoring = false
    }
    
    override func reset() {
        super.reset()
        stopMonitoring()
        heading = 0
        accuracy = 0
    }
}

// MARK: - Proximity Sensor Test
class ProximityTest: BaseDiagnosticTest {
    @Published var isNear = false
    @Published var isMonitoring = false
    
    init() {
        super.init(
            id: "proximity",
            title: "Proximity Sensor",
            description: "Cover sensor near camera",
            category: .sensors,
            isSupported: true
        )
    }
    
    override func run() async throws {
        status = .running
        startMonitoring()
    }
    
    func startMonitoring() {
        let device = UIDevice.current
        device.isProximityMonitoringEnabled = true
        
        // Set initial state immediately
        isNear = device.proximityState
        
        NotificationCenter.default.addObserver(
            forName: UIDevice.proximityStateDidChangeNotification,
            object: device,
            queue: .main
        ) { [weak self] _ in
            DispatchQueue.main.async {
                self?.isNear = device.proximityState
            }
        }
        
        isMonitoring = true
    }
    
    func confirmSuccess() {
        markPassed(metadata: ["state": isNear ? "near" : "far"])
    }
    
    func stopMonitoring() {
        UIDevice.current.isProximityMonitoringEnabled = false
        NotificationCenter.default.removeObserver(self)
        isMonitoring = false
    }
    
    override func reset() {
        super.reset()
        stopMonitoring()
        isNear = false
    }
}

// MARK: - Ambient Light Test
class AmbientLightTest: BaseDiagnosticTest {
    @Published var brightnessLevel: Float = 0
    @Published var isMonitoring = false
    
    private var monitoringTask: Task<Void, Never>?
    
    init() {
        super.init(
            id: "ambient_light",
            title: "Ambient Light",
            description: "Cover/uncover device to see brightness change",
            category: .sensors,
            isSupported: true
        )
    }
    
    override func run() async throws {
        status = .running
        startMonitoring()
    }
    
    func startMonitoring() {
        // Get initial brightness
        updateBrightness()
        
        // Also observe manual brightness changes
        NotificationCenter.default.addObserver(
            forName: UIScreen.brightnessDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.updateBrightness()
            }
        }
        
        isMonitoring = true
        
        // Poll brightness continuously
        monitoringTask = Task { @MainActor in
            while !Task.isCancelled {
                updateBrightness()
                try? await Task.sleep(nanoseconds: 100_000_000) // Update every 0.1 seconds
            }
        }
    }
    
    @MainActor
    private func updateBrightness() {
        if let screen = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?.screen {
            brightnessLevel = Float(screen.brightness)
        }
    }
    
    func confirmSuccess() {
        markPassed(metadata: ["brightness": String(format: "%.2f", brightnessLevel)])
    }
    
    func stopMonitoring() {
        monitoringTask?.cancel()
        monitoringTask = nil
        NotificationCenter.default.removeObserver(self)
        isMonitoring = false
    }
    
    override func reset() {
        super.reset()
        stopMonitoring()
        brightnessLevel = 0
    }
}
