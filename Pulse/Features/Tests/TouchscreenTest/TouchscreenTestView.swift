import SwiftUI

struct TouchscreenTestView: View {
    @ObservedObject var test: TouchscreenTest
    @Environment(\.dismiss) private var dismiss

    private let columns = 3
    private let rows = 3

    private var progress: Double {
        Double(test.touchedCells.count) / Double(columns * rows)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                PulseTheme.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    ForEach(0..<rows, id: \.self) { row in
                        HStack(spacing: 0) {
                            ForEach(0..<columns, id: \.self) { column in
                                let cellID = row * columns + column
                                let isTouched = test.touchedCells.contains(cellID)

                                ZStack {
                                    Rectangle()
                                        .fill(isTouched ? PulseTheme.success.opacity(0.18) : PulseTheme.surface)

                                    if isTouched {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.system(size: 48, weight: .semibold))
                                            .foregroundStyle(PulseTheme.success)
                                    } else {
                                        Text("\(cellID + 1)")
                                            .font(.system(size: 22, weight: .bold, design: .rounded))
                                            .foregroundStyle(PulseTheme.textSecondary)
                                    }

                                    Rectangle()
                                        .strokeBorder(PulseTheme.divider, lineWidth: 1)
                                }
                            }
                        }
                    }
                }
                .ignoresSafeArea()

                ForEach(Array(test.touchPoints.enumerated()), id: \.offset) { _, point in
                    Circle()
                        .fill(PulseTheme.accent.opacity(0.45))
                        .frame(width: 64, height: 64)
                        .overlay(Circle().stroke(PulseTheme.accent, lineWidth: 2))
                        .position(point)
                        .allowsHitTesting(false)
                }

                LinearGradient(
                    colors: [Color.black.opacity(0.6), .clear, Color.black.opacity(0.86)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                .allowsHitTesting(false)

            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        test.registerTouch(at: value.location, in: geometry.size, columns: columns, rows: rows)
                    }
            )
            // Reserve the system top and bottom regions for the HUD. This keeps
            // the custom header out from underneath the status bar and keeps
            // the instruction panel above the tab bar on every device size.
            .safeAreaInset(edge: .top, spacing: 0) {
                PulseTestHeader(
                    title: "Touchscreen",
                    status: test.status,
                    onClose: { dismiss() },
                    onSkip: { test.markSkipped(reason: "User skipped test") }
                )
                .padding(.top, PulseSpacing.xs)
                .padding(.bottom, PulseSpacing.sm)
                .background(PulseTheme.background.opacity(0.82))
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                PulseTestPanel {
                    VStack(spacing: PulseSpacing.sm) {
                        HStack {
                            Text("Touch every area")
                                .font(.headline)
                                .foregroundStyle(PulseTheme.textPrimary)
                            Spacer()
                            Text("\(test.touchedCells.count)/9")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(test.touchedCells.count == 9 ? PulseTheme.success : PulseTheme.accent)
                        }

                        ProgressView(value: progress)
                            .tint(PulseTheme.accent)

                        Text("Tap each grid cell to verify touch registration.")
                            .font(.caption)
                            .foregroundStyle(PulseTheme.textSecondary)
                    }
                    .allowsHitTesting(false)
                }
                .padding(.bottom, PulseSpacing.sm)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .pulseTestSceneStyle()
        // Keep the system status area visible and let the safe-area inset above
        // place the custom header beneath it.
        .statusBar(hidden: false)
        .onAppear {
            test.reset()
            Task { try? await test.run() }
        }
        .onChange(of: test.status) { _, status in
            if status == .passed || status == .failed || status == .skipped {
                dismiss()
            }
        }
    }
}
