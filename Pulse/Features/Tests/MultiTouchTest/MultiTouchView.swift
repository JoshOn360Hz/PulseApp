import UIKit
import SwiftUI

// UIKit view for proper multi-touch handling
class MultiTouchUIView: UIView {
    var onTouchesChanged: (([UUID: CGPoint]) -> Void)?
    private var activeTouches: [UITouch: UUID] = [:]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isMultipleTouchEnabled = true
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            activeTouches[touch] = UUID()
        }
        updateTouches()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateTouches()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            activeTouches.removeValue(forKey: touch)
        }
        updateTouches()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            activeTouches.removeValue(forKey: touch)
        }
        updateTouches()
    }
    
    private func updateTouches() {
        var touchDict: [UUID: CGPoint] = [:]
        for (touch, uuid) in activeTouches {
            touchDict[uuid] = touch.location(in: self)
        }
        onTouchesChanged?(touchDict)
    }
}

// SwiftUI wrapper
struct MultiTouchView: UIViewRepresentable {
    let onTouchesChanged: ([UUID: CGPoint]) -> Void
    
    func makeUIView(context: Context) -> MultiTouchUIView {
        let view = MultiTouchUIView()
        view.onTouchesChanged = onTouchesChanged
        return view
    }
    
    func updateUIView(_ uiView: MultiTouchUIView, context: Context) {
        uiView.onTouchesChanged = onTouchesChanged
    }
}
