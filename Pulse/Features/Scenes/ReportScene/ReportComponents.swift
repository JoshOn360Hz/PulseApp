import SwiftUI

struct ReportFact: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack(alignment: .top, spacing: PulseSpacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(PulseTheme.accent)
                .frame(width: 24, height: 24)
                .background(PulseTheme.accent.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(label.uppercased())
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .tracking(0.7)
                    .foregroundStyle(PulseTheme.textSecondary)

                Text(value)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(PulseTheme.textPrimary)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label): \(value)")
    }
}

struct CategoryResultsCard: View {
    let category: TestCategory
    let results: [TestResult]
    let engine: DiagnosticEngine

    private var passedCount: Int {
        results.filter { $0.status == .passed }.count
    }

    private var failedCount: Int {
        results.filter { $0.status == .failed }.count
    }

    var body: some View {
        PulseCard {
            VStack(alignment: .leading, spacing: PulseSpacing.md) {
                HStack(spacing: PulseSpacing.sm) {
                    Image(systemName: category.pulseIcon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(PulseTheme.accent)
                        .frame(width: 30, height: 30)
                        .background(PulseTheme.accent.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 9, style: .continuous))

                    Text(category.rawValue)
                        .font(.headline)
                        .foregroundStyle(PulseTheme.textPrimary)

                    Spacer()

                    Text("\(passedCount)/\(results.count)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(failedCount > 0 ? PulseTheme.failure : PulseTheme.success)
                }

                Divider().overlay(PulseTheme.divider)

                VStack(spacing: PulseSpacing.sm) {
                    ForEach(results) { result in
                        if let test = engine.tests.first(where: { $0.id == result.testId }) {
                            resultRow(test: test, result: result)
                        }
                    }
                }
            }
        }
    }

    private func resultRow(test: any DiagnosticTest, result: TestResult) -> some View {
        VStack(alignment: .leading, spacing: PulseSpacing.xs) {
            HStack(spacing: PulseSpacing.sm) {
                Image(systemName: statusIcon(for: result.status))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(statusColor(for: result.status))
                    .frame(width: 22)

                Text(test.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(PulseTheme.textPrimary)

                Spacer()

                Text(result.status.rawValue)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(statusColor(for: result.status))
            }

            if let failureReason = result.failureReason {
                Text(failureReason)
                    .font(.caption)
                    .foregroundStyle(PulseTheme.textSecondary)
                    .padding(.leading, 30)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(test.title), \(result.status.rawValue)\(result.failureReason.map { ", \($0)" } ?? "")")
    }

    private func statusColor(for status: TestStatus) -> Color {
        switch status {
        case .passed: return PulseTheme.success
        case .failed: return PulseTheme.failure
        case .skipped: return PulseTheme.warning
        case .running: return PulseTheme.accent
        case .notStarted: return PulseTheme.unsupported
        }
    }

    private func statusIcon(for status: TestStatus) -> String {
        switch status {
        case .passed: return "checkmark.circle.fill"
        case .failed: return "exclamationmark.circle.fill"
        case .skipped: return "minus.circle.fill"
        case .running: return "dot.radiowaves.left.and.right"
        case .notStarted: return "circle.dashed"
        }
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
