import SwiftUI

struct DeadPixelTestView: View {
    @ObservedObject var test: DeadPixelTest
    @Environment(\.dismiss) private var dismiss
    @State private var showControls = true

    private var textColor: Color {
        test.currentColor == .white ? .black : .white
    }

    var body: some View {
        ZStack {
            test.currentColor.color
                .ignoresSafeArea()

            if showControls {
                LinearGradient(
                    colors: [Color.black.opacity(0.65), .clear, Color.black.opacity(0.92)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    header
                    Spacer()
                    controls
                }
                .transition(.opacity)
            }

            if test.hasCompletedAllColors {
                completionCard
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
        .onAppear {
            test.reset()
            Task { try? await test.run() }
        }
        .onChange(of: test.status) { _, status in
            if status == .passed || status == .failed || status == .skipped {
                dismiss()
            }
        }
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    guard !test.hasCompletedAllColors else { return }
                    if value.translation.width < 0 {
                        test.nextColor()
                    } else if value.translation.width > 0 {
                        test.previousColor()
                    }
                }
        )
    }

    private var header: some View {
        HStack(spacing: PulseSpacing.sm) {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(textColor)
                    .frame(width: 42, height: 42)
                    .background(Color.black.opacity(0.28))
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Display inspection")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(textColor)
            }

            Spacer()

            Button(action: {
                withAnimation(.easeOut(duration: 0.2)) {
                    showControls.toggle()
                }
            }) {
                Image(systemName: showControls ? "eye.slash" : "eye")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(textColor)
                    .frame(width: 42, height: 42)
                    .background(Color.black.opacity(0.28))
                    .clipShape(Circle())
            }

            Button(action: { test.markSkipped(reason: "User skipped test") }) {
                Text("Skip")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(textColor)
                    .padding(.horizontal, PulseSpacing.sm)
                    .padding(.vertical, PulseSpacing.xs)
                    .background(Color.black.opacity(0.28))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, PulseSpacing.lg)
        .padding(.top, PulseSpacing.sm)
    }

    private var controls: some View {
        PulseTestPanel {
            VStack(alignment: .leading, spacing: PulseSpacing.lg) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Check for dead pixels")
                            .font(.system(size: 21, weight: .bold, design: .rounded))
                            .foregroundStyle(PulseTheme.textPrimary)

                        Text("Look closely at each solid color, especially around the edges.")
                            .font(.subheadline)
                            .foregroundStyle(PulseTheme.textSecondary)
                    }

                    Spacer()

                    Text("\(test.currentColorIndex + 1)/\(test.totalColors)")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(PulseTheme.accent)
                }

                HStack(spacing: PulseSpacing.xs) {
                    ForEach(Array(PixelTestColor.allCases.enumerated()), id: \.offset) { index, color in
                        Capsule()
                            .fill(index <= test.currentColorIndex ? PulseTheme.accent : PulseTheme.surfaceRaised)
                            .frame(maxWidth: .infinity)
                            .frame(height: 6)
                    }
                }

                HStack(spacing: PulseSpacing.sm) {
                    Button {
                        test.previousColor()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .bold))
                            .frame(width: 48, height: 48)
                    }
                    .buttonStyle(PulseSecondaryButtonStyle())
                    .disabled(test.currentColorIndex == 0)

                    Button {
                        test.nextColor()
                    } label: {
                        PulseButtonLabel(
                            title: test.currentColorIndex == test.totalColors - 1 ? "Finish color scan" : "Next color",
                            icon: "chevron.right"
                        )
                    }
                    .buttonStyle(PulsePrimaryButtonStyle())
                }
            }
        }
    }

    private var completionCard: some View {
        VStack(spacing: PulseSpacing.lg) {
            Image(systemName: "display.2")
                .font(.system(size: 42, weight: .medium))
                .foregroundStyle(PulseTheme.accent)

            VStack(spacing: PulseSpacing.xs) {
                Text("Color scan complete")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(PulseTheme.textPrimary)

                Text("Did you notice any dead, bright, or stuck pixels?")
                    .font(.subheadline)
                    .foregroundStyle(PulseTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: PulseSpacing.sm) {
                PulseTestActionButton(
                    title: "No issues found",
                    icon: "checkmark.circle.fill",
                    role: .primary,
                    action: test.confirmNoDeadPixels
                )

                PulseTestActionButton(
                    title: "Report display issue",
                    icon: "xmark.circle",
                    role: .destructive,
                    action: test.confirmDeadPixelsFound
                )
            }
        }
        .padding(PulseSpacing.xl)
        .frame(maxWidth: 360)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(PulseTheme.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(PulseTheme.divider, lineWidth: 1)
                }
        )
        .padding(PulseSpacing.lg)
    }
}
