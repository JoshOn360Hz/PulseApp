import SwiftUI
import Combine

// MARK: - Touchscreen Test
class TouchscreenTest: BaseDiagnosticTest {
    @Published var touchPoints: [CGPoint] = []
    private var requiredTouches = 9 // 3x3 grid
    var touchedCells: Set<Int> = []
    
    init() {
        super.init(
            id: "touchscreen",
            title: "Touchscreen",
            description: "Tap all grid cells to verify touch registration",
            category: .inputInteraction,
            isSupported: true
        )
    }
    
    override func run() async throws {
        status = .running
        // Test runs interactively via the view
    }
    
    func registerTouch(at point: CGPoint, in gridSize: CGSize, columns: Int, rows: Int) {
        touchPoints.append(point)
        
        let cellWidth = gridSize.width / CGFloat(columns)
        let cellHeight = gridSize.height / CGFloat(rows)
        
        let col = Int(point.x / cellWidth)
        let row = Int(point.y / cellHeight)
        let cellIndex = row * columns + col
        
        touchedCells.insert(cellIndex)
        
        if touchedCells.count >= requiredTouches {
            markPassed(metadata: [
                "touches": "\(touchPoints.count)",
                "cells_covered": "\(touchedCells.count)/\(requiredTouches)"
            ])
        }
    }
    
    override func reset() {
        super.reset()
        touchPoints.removeAll()
        touchedCells.removeAll()
    }
}
