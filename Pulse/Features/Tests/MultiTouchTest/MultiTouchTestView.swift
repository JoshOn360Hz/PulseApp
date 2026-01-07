import SwiftUI

struct MultiTouchTestView: View {
    @ObservedObject var test: MultiTouchTest
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.1),
                    Color.cyan.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            // Multi-touch tracking view
            MultiTouchView { touches in
                test.updateTouches(touches)
            }
            
            // Active touch indicators
            activeTouchIndicators
            
            // Header card
            VStack {
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "hand.point.up.left.and.text")
                            .font(.title2)
                            .foregroundColor(.blue)
                        
                        Text("Multi-Touch Test")
                            .font(.headline)
                    }
                    
                    Text("Place 2 or more fingers on screen")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .allowsHitTesting(false)
                
                Spacer()
                
                // Stats card
                VStack(spacing: 16) {
                    HStack(spacing: 30) {
                        VStack(spacing: 6) {
                            Text("\(test.activeTouches.count)")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(.blue)
                            Text("Current")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                            .frame(height: 50)
                        
                        VStack(spacing: 6) {
                            Text("\(test.maxSimultaneousTouches)")
                                .font(.system(size: 42, weight: .bold))
                                .foregroundColor(.green)
                            Text("Maximum")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if test.status == .passed {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                            Text("Test Passed!")
                                .font(.headline)
                                .foregroundColor(.green)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.15))
                        )
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .allowsHitTesting(false)
            }
        }
        .navigationTitle(test.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    test.markSkipped(reason: "User skipped test")
                }) {
                    Text("Skip")
                        .foregroundColor(.orange)
                        .fontWeight(.medium)
                }
            }
        }
        .onAppear {
            test.reset()
            Task {
                try? await test.run()
            }
        }
        .onChange(of: test.status) { newStatus in
            if newStatus == .passed || newStatus == .failed || newStatus == .skipped {
                dismiss()
            }
        }
    }
    
    @ViewBuilder
    private var activeTouchIndicators: some View {
        let touchKeys = Array(test.activeTouches.keys).enumerated()
        ForEach(Array(touchKeys), id: \.element) { index, touchId in
            if let point = test.activeTouches[touchId] {
                TouchIndicator(touchNumber: index + 1, point: point)
            }
        }
        .animation(.spring(response: 0.3), value: test.activeTouches.keys.count)
    }
}

struct TouchIndicator: View {
    let touchNumber: Int
    let point: CGPoint
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.green, .green.opacity(0.4), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 40
                    )
                )
                .frame(width: 80, height: 80)
            
            Circle()
                .fill(Color.green)
                .frame(width: 50, height: 50)
            
            Text("\(touchNumber)")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
        }
        .position(point)
        .shadow(color: Color.green.opacity(0.4), radius: 10)
        .allowsHitTesting(false)
        .transition(.scale.combined(with: .opacity))
    }
}
