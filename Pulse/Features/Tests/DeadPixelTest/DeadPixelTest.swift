import Foundation
import SwiftUI
import Combine
enum PixelTestColor: CaseIterable {
    case white
    case black
    case red
    case green
    case blue
    
    var color: Color {
        switch self {
        case .white: return .white
        case .black: return .black
        case .red: return .red
        case .green: return .green
        case .blue: return .blue
        }
    }
    
    var name: String {
        switch self {
        case .white: return "White"
        case .black: return "Black"
        case .red: return "Red"
        case .green: return "Green"
        case .blue: return "Blue"
        }
    }
}

class DeadPixelTest: BaseDiagnosticTest {
    @Published var currentColorIndex = 0
    @Published var userFoundDeadPixels = false
    @Published var hasCompletedAllColors = false
    
    init() {
        super.init(
            id: "dead-pixel",
            title: "Dead Pixel Test",
            description: "Check for dead or stuck pixels",
            category: .display,
            isSupported: true
        )
    }
    
    var currentColor: PixelTestColor {
        PixelTestColor.allCases[currentColorIndex]
    }
    
    var totalColors: Int {
        PixelTestColor.allCases.count
    }
    
    override func run() async throws {
        status = .running
        
        // Wait for user to cycle through all colors
        while !hasCompletedAllColors {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
        
        // Test completes when user confirms - we don't auto-pass/fail here
    }
    
    func nextColor() {
        if currentColorIndex < PixelTestColor.allCases.count - 1 {
            currentColorIndex += 1
        } else {
            hasCompletedAllColors = true
        }
    }
    
    func previousColor() {
        if currentColorIndex > 0 {
            currentColorIndex -= 1
        }
    }
    
    func confirmNoDeadPixels() {
        userFoundDeadPixels = false
        markPassed(metadata: ["deadPixelsFound": "false"])
    }
    
    func confirmDeadPixelsFound() {
        userFoundDeadPixels = true
        markFailed(reason: "Dead or stuck pixels detected by user", metadata: ["deadPixelsFound": "true"])
    }
    
    override func reset() {
        super.reset()
        currentColorIndex = 0
        userFoundDeadPixels = false
        hasCompletedAllColors = false
    }
}
