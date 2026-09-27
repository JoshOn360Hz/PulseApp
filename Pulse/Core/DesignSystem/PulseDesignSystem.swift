import SwiftUI

enum PulseTheme {
    static let background = Color(hex: 0x080B12)
    static let surface = Color(hex: 0x111722)
    static let surfaceRaised = Color(hex: 0x182131)
    static let surfaceMuted = Color(hex: 0x0D121C)
    static let divider = Color.white.opacity(0.09)
    static let textPrimary = Color(hex: 0xF4F7FB)
    static let textSecondary = Color(hex: 0x9AA8BB)
    static let accent = Color(hex: 0x62D9FF)
    static let accentDeep = Color(hex: 0x2B8CFF)
    static let success = Color(hex: 0x65E6A5)
    static let warning = Color(hex: 0xFFBE5C)
    static let failure = Color(hex: 0xFF6B7A)
    static let unsupported = Color(hex: 0x77869A)
    static let contentMaxWidth: CGFloat = 760
}

enum PulseSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

enum PulseRadius {
    static let card: CGFloat = 20
    static let control: CGFloat = 14
    static let pill: CGFloat = 999
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

struct PulseScreen<Content: View>: View {
    let title: String
    let subtitle: String?
    @ViewBuilder let content: () -> Content

    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content
    }

    var body: some View {
        ZStack {
            PulseTheme.background
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: PulseSpacing.xl) {
                    VStack(alignment: .leading, spacing: PulseSpacing.xs) {
                        Text(title)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(PulseTheme.textPrimary)

                        if let subtitle {
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundStyle(PulseTheme.textSecondary)
                        }
                    }

                    content()
                }
                .frame(maxWidth: PulseTheme.contentMaxWidth, alignment: .leading)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.horizontal, PulseSpacing.lg)
                .padding(.top, PulseSpacing.lg)
                .padding(.bottom, PulseSpacing.xxl)
            }
            .scrollIndicators(.hidden)
        }
        .toolbarBackground(PulseTheme.background, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

struct PulseCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(PulseSpacing.lg)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(PulseTheme.surface)
            .overlay {
                RoundedRectangle(cornerRadius: PulseRadius.card, style: .continuous)
                    .stroke(PulseTheme.divider, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: PulseRadius.card, style: .continuous))
    }
}

struct PulseSectionHeader: View {
    let icon: String
    let title: String
    let subtitle: String?

    init(icon: String, title: String, subtitle: String? = nil) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
    }

    var body: some View {
        HStack(spacing: PulseSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(PulseTheme.accent)
                .frame(width: 32, height: 32)
                .background(PulseTheme.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(PulseTheme.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(PulseTheme.textSecondary)
                }
            }

            Spacer()
        }
    }
}

struct PulseButtonLabel: View {
    let title: String
    let icon: String

    var body: some View {
        Label(title, systemImage: icon)
            .font(.system(size: 15, weight: .semibold, design: .rounded))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
    }
}

struct PulsePrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(PulseTheme.background)
            .background(
                LinearGradient(
                    colors: [PulseTheme.accent, PulseTheme.accentDeep],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: PulseRadius.control, style: .continuous))
            .opacity(configuration.isPressed ? 0.78 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

struct PulseSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(PulseTheme.textPrimary)
            .background(PulseTheme.surfaceRaised)
            .overlay {
                RoundedRectangle(cornerRadius: PulseRadius.control, style: .continuous)
                    .stroke(PulseTheme.divider, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: PulseRadius.control, style: .continuous))
            .opacity(configuration.isPressed ? 0.72 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

struct PulseStatusBadge: View {
    let status: TestStatus

    private var color: Color {
        switch status {
        case .passed: return PulseTheme.success
        case .failed: return PulseTheme.failure
        case .skipped: return PulseTheme.warning
        case .running: return PulseTheme.accent
        case .notStarted: return PulseTheme.unsupported
        }
    }

    private var icon: String {
        switch status {
        case .passed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        case .skipped: return "minus.circle.fill"
        case .running: return "dot.radiowaves.left.and.right"
        case .notStarted: return "circle.dashed"
        }
    }

    var body: some View {
        Label(status.rawValue, systemImage: icon)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(color)
            .padding(.horizontal, PulseSpacing.sm)
            .padding(.vertical, PulseSpacing.xs)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
            .accessibilityLabel("Status: \(status.rawValue)")
    }
}

struct PulseMetricCard: View {
    let title: String
    let value: Int
    let icon: String
    let tint: Color

    var body: some View {
        VStack(alignment: .center, spacing: PulseSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 30, height: 30)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

            Text("\(value)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(PulseTheme.textPrimary)

            Text(title)
                .font(.caption)
                .foregroundStyle(PulseTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

struct PulseProgressRing: View {
    let progress: Double
    let label: String
    let caption: String
    var tint: Color = PulseTheme.accent

    var body: some View {
        ZStack {
            Circle()
                .stroke(PulseTheme.surfaceRaised, lineWidth: 12)

            Circle()
                .trim(from: 0, to: max(0, min(progress, 1)))
                .stroke(
                    tint,
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text(label)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(PulseTheme.textPrimary)
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(PulseTheme.textSecondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label) \(caption)")
    }
}

extension TestCategory {
    var pulseIcon: String {
        switch self {
        case .inputInteraction: return "hand.tap"
        case .display: return "display"
        case .cameraMedia: return "camera"
        case .sensors: return "sensor"
        case .biometrics: return "faceid"
        case .systemConnectivity: return "cpu"
        }
    }
}
