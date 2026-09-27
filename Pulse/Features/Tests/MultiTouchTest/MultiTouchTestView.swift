import SwiftUI

struct MultiTouchTestView: View {
    @ObservedObject var test: MultiTouchTest
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            PulseTheme.background
                .ignoresSafeArea()

            MultiTouchView { touches in
                test.updateTouches(touches)
            }
            .ignoresSafeArea()

            activeTouchIndicators

            LinearGradient(
                colors: [Color.black.opacity(0.58), .clear, Color.black.opacity(0.86)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                PulseTestHeader(
                    title: "Multi-Touch",
                    status: test.status,
                    onClose: { dismiss() },
                    onSkip: { test.markSkipped(reason: "User skipped test") }
                )

                Spacer()

                PulseTestPanel {
                    VStack(spacing: PulseSpacing.md) {
                        HStack(spacing: PulseSpacing.sm) {
                            PulseTestValueCard(label: "Current", value: "\(test.activeTouches.count)", icon: "hand.point.up", tint: PulseTheme.accent)
                            PulseTestValueCard(label: "Peak", value: "\(test.maxSimultaneousTouches)", icon: "hand.point.up.left.fill", tint: PulseTheme.success)
                            PulseTestValueCard(label: "Required", value: "2+", icon: "checkmark", tint: PulseTheme.warning)
                        }

                        Text(test.status == .passed ? "Multi-touch detected" : "Place two or more fingers anywhere on the screen")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(test.status == .passed ? PulseTheme.success : PulseTheme.textSecondary)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.center)
                    }
                    .allowsHitTesting(false)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .pulseTestSceneStyle()
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

    @ViewBuilder
    private var activeTouchIndicators: some View {
        let touchKeys = Array(test.activeTouches.keys).enumerated()
        ForEach(Array(touchKeys), id: \.element) { index, touchID in
            if let point = test.activeTouches[touchID] {
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
                .fill(PulseTheme.accent.opacity(0.2))
                .frame(width: 86, height: 86)

            Circle()
                .fill(PulseTheme.accent)
                .frame(width: 50, height: 50)

            Text("\(touchNumber)")
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundStyle(PulseTheme.background)
        }
        .position(point)
        .shadow(color: PulseTheme.accent.opacity(0.45), radius: 14)
        .allowsHitTesting(false)
        .transition(.scale.combined(with: .opacity))
    }
}
