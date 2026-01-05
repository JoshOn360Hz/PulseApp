import SwiftUI
import Combine

// Multi-Touch Test
class MultiTouchTest: BaseDiagnosticTest {
    @Published var activeTouches: [UUID: CGPoint] = [:]
    @Published var maxSimultaneousTouches = 0
    private let requiredTouches = 2
    
    init() {
        super.init(
            id: "multitouch",
            title: "Multi-Touch",
            description: "Touch with 2+ fingers simultaneously",
            category: .inputInteraction,
            isSupported: true
        )
    }
    
    override func run() async throws {
        status = .running
        // Test runs interactively via the view
    }
    
    func updateTouches(_ touches: [UUID: CGPoint]) {
        activeTouches = touches
        maxSimultaneousTouches = max(maxSimultaneousTouches, touches.count)
        
        if maxSimultaneousTouches >= requiredTouches {
            markPassed(metadata: [
                "max_simultaneous": "\(maxSimultaneousTouches)",
                "current": "\(touches.count)"
            ])
        }
    }
    
    override func reset() {
        super.reset()
        activeTouches.removeAll()
        maxSimultaneousTouches = 0
    }
}
