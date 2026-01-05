import Foundation
import UIKit
import Combine

class PowerButtonTest: BaseDiagnosticTest {
    @Published var waitingForUserConfirmation = false
    @Published var deviceWentToSleep = false
    
    private var appDidEnterBackgroundTime: Date?
    private var backgroundObserver: NSObjectProtocol?
    private var foregroundObserver: NSObjectProtocol?
    
    init() {
        super.init(
            id: "power-button",
            title: "Power Button",
            description: "Test power button functionality",
            category: .inputInteraction,
            isSupported: true
        )
    }
    
    override func run() async throws {
        status = .running
        
        await MainActor.run {
            setupObservers()
            waitingForUserConfirmation = false
        }
        
        // Wait for the app to go to background (power button pressed)
        let startTime = Date()
        while appDidEnterBackgroundTime == nil && Date().timeIntervalSince(startTime) < 30 {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
        
        if appDidEnterBackgroundTime != nil {
            // App went to background, now wait for user confirmation
            await MainActor.run {
                waitingForUserConfirmation = true
            }
            
            // Wait for user confirmation or timeout
            let confirmationStart = Date()
            while !deviceWentToSleep && Date().timeIntervalSince(confirmationStart) < 30 {
                try await Task.sleep(nanoseconds: 100_000_000)
            }
        }
        
        await MainActor.run {
            cleanup()
        }
        
        // Don't auto-pass or fail - wait for user input in the view
    }
    
    private func setupObservers() {
        backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.appDidEnterBackgroundTime = Date()
        }
        
        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            // Device came back from background
        }
    }
    
    private func cleanup() {
        if let observer = backgroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = foregroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    func confirmDeviceSlept() {
        deviceWentToSleep = true
        markPassed(metadata: ["backgroundTime": appDidEnterBackgroundTime?.description ?? "unknown"])
    }
    
    func confirmDeviceDidNotSleep() {
        markFailed(reason: "Device did not go to sleep when power button was pressed", metadata: [:])
    }
    
    override func reset() {
        super.reset()
        waitingForUserConfirmation = false
        deviceWentToSleep = false
        appDidEnterBackgroundTime = nil
        cleanup()
    }
}
