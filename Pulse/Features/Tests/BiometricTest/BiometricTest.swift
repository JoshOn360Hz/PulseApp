import LocalAuthentication
import SwiftUI
import Combine

// Biometric Test
class BiometricTest: BaseDiagnosticTest {
    @Published var biometricType: LABiometryType = .none
    @Published var isAvailable = false
    
    private let context = LAContext()
    
    init() {
        super.init(
            id: "biometrics",
            title: "Biometrics",
            description: "Test Face ID or Touch ID",
            category: .biometrics,
            isSupported: true
        )
        checkBiometricAvailability()
    }
    
    private func checkBiometricAvailability() {
        var error: NSError?
        isAvailable = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        biometricType = context.biometryType
        
        if !isAvailable {
            self.isSupported = false
        }
    }
    
    override func run() async throws {
        status = .running
        
        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Authenticate to test biometric sensor"
            )
            
            if success {
                let typeString = biometricType == .faceID ? "Face ID" : "Touch ID"
                markPassed(metadata: ["type": typeString])
            } else {
                markFailed(reason: "Authentication failed")
            }
        } catch {
            markFailed(reason: error.localizedDescription)
        }
    }
    
    override func reset() {
        super.reset()
    }
}
