import Foundation
import CoreLocation
import Combine

class GPSTest: BaseDiagnosticTest {
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation?
    @Published var accuracy: CLLocationAccuracy?
    @Published var isUpdatingLocation = false
    
    private let locationManager = CLLocationManager()
    private var locationDelegate: LocationDelegate?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        super.init(
            id: "gps",
            title: "GPS Test",
            description: "Test location services and GPS accuracy",
            category: .systemConnectivity,
            isSupported: true
        )
    }
    
    override func run() async throws {
        status = .running
        
        // Set up location manager
        locationDelegate = LocationDelegate(test: self)
        locationManager.delegate = locationDelegate
        locationManager.desiredAccuracy = kCLLocationAccuracyReduced
        
        // Check authorization status
        authorizationStatus = locationManager.authorizationStatus
        
        if authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        // Wait for user to confirm or fail
        while status == .running {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
    }
    
    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            return
        }
        
        isUpdatingLocation = true
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        isUpdatingLocation = false
        locationManager.stopUpdatingLocation()
    }
    
    func confirmSuccess() {
        stopLocationUpdates()
        let metadata: [String: String] = [
            "accuracy": accuracy != nil ? "\(accuracy!)" : "unknown",
            "authorizationStatus": "\(authorizationStatus.rawValue)"
        ]
        markPassed(metadata: metadata)
    }
    
    override func reset() {
        super.reset()
        currentLocation = nil
        accuracy = nil
        isUpdatingLocation = false
        stopLocationUpdates()
    }
}

// MARK: - Location Delegate
class LocationDelegate: NSObject, CLLocationManagerDelegate {
    weak var test: GPSTest?
    
    init(test: GPSTest) {
        self.test = test
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        test?.authorizationStatus = manager.authorizationStatus
        
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            test?.startLocationUpdates()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        test?.currentLocation = location
        test?.accuracy = location.horizontalAccuracy
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        test?.stopLocationUpdates()
    }
}
