import SwiftUI
import Combine

struct TouchscreenTestView: View {
    @ObservedObject var test: TouchscreenTest
    @Environment(\.dismiss) var dismiss
    let columns = 3
    let rows = 3
    
    var progress: Double {
        Double(test.touchedCells.count) / Double(columns * rows)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                // Grid
                VStack(spacing: 0) {
                    ForEach(0..<rows, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<columns, id: \.self) { col in
                                let cellId = row * columns + col
                                let isTouched = test.touchedCells.contains(cellId)
                                
                                ZStack {
                                    Rectangle()
                                        .fill(isTouched ? Color.green.opacity(0.2) : Color(.systemGray6))
                                    
                                    if isTouched {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 60))
                                            .foregroundColor(.green)
                                    } else {
                                        Text("\(cellId + 1)")
                                            .font(.system(size: 24, weight: .medium))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    // Border
                                    Rectangle()
                                        .strokeBorder(Color(.systemGray4), lineWidth: 1)
                                }
                            }
                        }
                    }
                }
                .ignoresSafeArea()
                
                // Touch ripple indicators
                ForEach(Array(test.touchPoints.enumerated()), id: \.offset) { index, point in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [.green.opacity(0.4), .green.opacity(0.2), .clear],
                                center: .center,
                                startRadius: 0,
                                endRadius: 40
                            )
                        )
                        .frame(width: 80, height: 80)
                        .position(point)
                        .allowsHitTesting(false)
                }
                
                // Top bar with progress
                VStack(spacing: 0) {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                                .frame(width: 44, height: 44)
                                .background(Circle().fill(Material.ultraThin))
                        }
                        
                        Spacer()
                        
                        VStack(spacing: 4) {
                            Text("\(test.touchedCells.count)/\(columns * rows)")
                                .font(.system(size: 18, weight: .bold))
                                .monospacedDigit()
                            
                            ProgressView(value: progress)
                                .tint(.green)
                                .frame(width: 100)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Capsule().fill(Material.ultraThin))
                        
                        Spacer()
                        
                        Button(action: {
                            test.markSkipped(reason: "User skipped test")
                        }) {
                            Text("Skip")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.orange)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Capsule().fill(Material.ultraThin))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 60)
                    .padding(.bottom, 20)
                    
                    Spacer()
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        test.registerTouch(
                            at: value.location,
                            in: geometry.size,
                            columns: columns,
                            rows: rows
                        )
                    }
            )
        }
        .ignoresSafeArea()
        .navigationBarHidden(true)
        .statusBar(hidden: false)
        .onAppear {
            test.reset()
            Task {
                try? await test.run()
            }
        }
        .onChange(of: test.status) {
            if test.status == .passed || test.status == .failed || test.status == .skipped {
                dismiss()
            }
        }
    }
}
