import Foundation
import CoreBluetooth
import Combine

class BluetoothTest: BaseDiagnosticTest {
    @Published var authorizationStatus: CBManagerAuthorization = .notDetermined
    @Published var bluetoothState: CBManagerState = .unknown
    @Published var discoveredDevices: [BluetoothDevice] = []
    @Published var isScanning = false
    
    private var centralManager: CBCentralManager?
    private var bluetoothDelegate: BluetoothDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        super.init(
            id: "bluetooth",
            title: "Bluetooth Test",
            description: "Test Bluetooth hardware and device scanning",
            category: .systemConnectivity,
            isSupported: true
        )
    }
    
    override func run() async throws {
        status = .running
        
        // Set up Bluetooth manager
        bluetoothDelegate = BluetoothDelegate(test: self)
        centralManager = CBCentralManager(delegate: bluetoothDelegate, queue: nil)
        
        // Check authorization status
        authorizationStatus = CBCentralManager.authorization
        
        // Wait for user to confirm or fail
        while status == .running {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
    }
    
    func startScanning() {
        guard bluetoothState == .poweredOn else {
            return
        }
        
        discoveredDevices.removeAll()
        isScanning = true
        centralManager?.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    func stopScanning() {
        isScanning = false
        centralManager?.stopScan()
    }
    
    func confirmSuccess() {
        stopScanning()
        let metadata: [String: String] = [
            "devicesFound": "\(discoveredDevices.count)",
            "bluetoothState": bluetoothStateText(bluetoothState),
            "authorizationStatus": authorizationStatusText(authorizationStatus)
        ]
        markPassed(metadata: metadata)
    }
    
    func bluetoothStateText(_ state: CBManagerState) -> String {
        switch state {
        case .unknown:
            return "Unknown"
        case .resetting:
            return "Resetting"
        case .unsupported:
            return "Unsupported"
        case .unauthorized:
            return "Unauthorized"
        case .poweredOff:
            return "Powered Off"
        case .poweredOn:
            return "Powered On"
        @unknown default:
            return "Unknown"
        }
    }
    
    func authorizationStatusText(_ status: CBManagerAuthorization) -> String {
        switch status {
        case .notDetermined:
            return "Not Determined"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        case .allowedAlways:
            return "Allowed"
        @unknown default:
            return "Unknown"
        }
    }
    
    override func reset() {
        super.reset()
        stopScanning()
        discoveredDevices.removeAll()
        centralManager = nil
        bluetoothDelegate = nil
    }
}

// Bluetooth Device Model
struct BluetoothDevice: Identifiable {
    let id: UUID
    let name: String?
    let rssi: Int
    
    var displayName: String {
        name ?? "Unknown Device"
    }
}

// Bluetooth Delegate
class BluetoothDelegate: NSObject, CBCentralManagerDelegate {
    weak var test: BluetoothTest?
    
    init(test: BluetoothTest) {
        self.test = test
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        test?.bluetoothState = central.state
        test?.authorizationStatus = CBCentralManager.authorization
        
        if central.state == .poweredOn {
            test?.startScanning()
        } else if central.state == .poweredOff || central.state == .unsupported {
            test?.stopScanning()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = BluetoothDevice(
            id: peripheral.identifier,
            name: peripheral.name,
            rssi: RSSI.intValue
        )
        
        // Add device if not already in list
        if let test = test, !test.discoveredDevices.contains(where: { $0.id == device.id }) {
            test.discoveredDevices.append(device)
        }
    }
}
