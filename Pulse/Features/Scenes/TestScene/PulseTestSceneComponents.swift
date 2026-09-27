import SwiftUI

struct PulseTestHeader: View {
    let title: String
    let status: TestStatus
    let onClose: () -> Void
    let onSkip: () -> Void
    @Environment(\.pulseIsAutoRunning) private var isAutoRunning
    @Environment(\.pulsePauseTestRun) private var pauseTestRun

    var body: some View {
        HStack(spacing: PulseSpacing.sm) {
            Button(action: {
                if isAutoRunning {
                    pauseTestRun()
                } else {
                    onClose()
                }
            }) {
                Image(systemName: isAutoRunning ? "pause.fill" : "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(PulseTheme.textPrimary)
                    .frame(width: 42, height: 42)
                    .background(PulseTheme.surface.opacity(0.92))
                    .clipShape(Circle())
            }

            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(PulseTheme.textPrimary)

            Spacer(minLength: PulseSpacing.sm)

            PulseStatusBadge(status: status)

            Button(action: onSkip) {
                Text("Skip")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(PulseTheme.warning)
                    .padding(.horizontal, PulseSpacing.sm)
                    .padding(.vertical, PulseSpacing.xs)
                    .background(PulseTheme.warning.opacity(0.14))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, PulseSpacing.lg)
        .padding(.top, PulseSpacing.sm)
    }
}

private struct PulseIsAutoRunningKey: EnvironmentKey {
    static let defaultValue = false
}

private struct PulsePauseTestRunKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var pulseIsAutoRunning: Bool {
        get { self[PulseIsAutoRunningKey.self] }
        set { self[PulseIsAutoRunningKey.self] = newValue }
    }

    var pulsePauseTestRun: () -> Void {
        get { self[PulsePauseTestRunKey.self] }
        set { self[PulsePauseTestRunKey.self] = newValue }
    }
}

struct PulseTestSceneModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(PulseTheme.background.ignoresSafeArea())
            .preferredColorScheme(.dark)
            .tint(PulseTheme.accent)
            .toolbarBackground(PulseTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar(.hidden, for: .tabBar)
            .statusBar(hidden: true)
            .scrollContentBackground(.hidden)
    }
}

extension View {
    func pulseTestSceneStyle() -> some View {
        modifier(PulseTestSceneModifier())
    }
}

struct PulseTestScrollScreen<Content: View>: View {
    let title: String
    let status: TestStatus
    let onClose: () -> Void
    let onSkip: () -> Void
    let content: Content

    init(
        title: String,
        status: TestStatus,
        onClose: @escaping () -> Void,
        onSkip: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.status = status
        self.onClose = onClose
        self.onSkip = onSkip
        self.content = content()
    }

    var body: some View {
        ZStack {
            PulseTheme.background
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: PulseSpacing.lg) {
                    PulseTestHeader(
                        title: title,
                        status: status,
                        onClose: onClose,
                        onSkip: onSkip
                    )

                    content
                }
                .padding(.top, PulseSpacing.sm)
                .padding(.bottom, PulseSpacing.xl)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .pulseTestSceneStyle()
    }
}

struct PulseTestHero: View {
    let icon: String
    let tint: Color
    var isActive = false

    var body: some View {
        ZStack {
            Circle()
                .fill(tint.opacity(0.12))
                .frame(width: 132, height: 132)

            Circle()
                .stroke(tint.opacity(0.28), lineWidth: 1)
                .frame(width: 104, height: 104)

            Image(systemName: icon)
                .font(.system(size: 48, weight: .medium))
                .foregroundStyle(tint)
                .symbolEffect(.pulse, isActive: isActive)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, PulseSpacing.sm)
    }
}

struct PulseTestValueCard: View {
    let label: String
    let value: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(spacing: PulseSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 30, height: 30)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(PulseTheme.textPrimary)

            Text(label)
                .font(.caption)
                .foregroundStyle(PulseTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, PulseSpacing.sm)
        .background(PulseTheme.surfaceRaised)
        .clipShape(RoundedRectangle(cornerRadius: PulseRadius.control, style: .continuous))
    }
}

struct PulseTestStatusRow: View {
    let icon: String
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        HStack(spacing: PulseSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 32, height: 32)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(title)
                .font(.subheadline)
                .foregroundStyle(PulseTheme.textSecondary)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(PulseTheme.textPrimary)
        }
    }
}

struct PulseTestPanel<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(PulseSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(PulseTheme.surface.opacity(0.97))
                    .overlay {
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .stroke(PulseTheme.divider, lineWidth: 1)
                    }
            )
            .padding(.horizontal, PulseSpacing.sm)
            .padding(.bottom, PulseSpacing.sm)
    }
}

struct PulseTestActionButton: View {
    let title: String
    let icon: String
    let role: ActionRole
    let action: () -> Void

    enum ActionRole {
        case primary
        case destructive
        case secondary
    }

    @ViewBuilder
    var body: some View {
        switch role {
        case .primary:
            button.buttonStyle(PulsePrimaryButtonStyle())
        case .destructive:
            button.buttonStyle(PulseDestructiveButtonStyle())
        case .secondary:
            button.buttonStyle(PulseSecondaryButtonStyle())
        }
    }

    private var button: some View {
        Button(action: action) {
            PulseButtonLabel(title: title, icon: icon)
        }
    }
}

struct PulseDestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(PulseTheme.failure)
            .background(PulseTheme.failure.opacity(0.12))
            .overlay {
                RoundedRectangle(cornerRadius: PulseRadius.control, style: .continuous)
                    .stroke(PulseTheme.failure.opacity(0.3), lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: PulseRadius.control, style: .continuous))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
