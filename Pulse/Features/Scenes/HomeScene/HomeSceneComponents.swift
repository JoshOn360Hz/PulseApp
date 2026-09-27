import SwiftUI

struct TestsTabView: View {
    @ObservedObject var engine: DiagnosticEngine
    @State private var selectedCategory: TestCategory?
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    private var isIPad: Bool {
        horizontalSizeClass == .regular && UIDevice.current.userInterfaceIdiom == .pad
    }

    private var visibleTests: [BaseDiagnosticTest] {
        let tests: [any DiagnosticTest]
        if let selectedCategory {
            tests = engine.testsByCategory(selectedCategory)
        } else {
            tests = engine.tests
        }

        // Production hardware diagnostics inherit from BaseDiagnosticTest.
        // Keeping the concrete observable here lets each card redraw immediately
        // when its hardware state changes.
        return tests.compactMap { $0 as? BaseDiagnosticTest }
    }

    private var completionProgress: Double {
        guard !engine.tests.isEmpty else { return 0 }
        return Double(engine.completedCount) / Double(engine.tests.count)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PulseTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: PulseSpacing.xl) {
                        overviewCard
                        metricsGrid
                        categoryFilter
                        testList
                    }
                    .frame(maxWidth: PulseTheme.contentMaxWidth)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, PulseSpacing.lg)
                    .padding(.top, PulseSpacing.lg)
                    .padding(.bottom, PulseSpacing.xxl)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Tests")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(PulseTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        engine.resetAllTests()
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .accessibilityLabel("Reset all test results")
                }
            }
        }
    }

    private var overviewCard: some View {
        PulseCard {
            VStack(alignment: .leading, spacing: PulseSpacing.lg) {
                HStack(alignment: .top, spacing: PulseSpacing.lg) {
                    VStack(alignment: .leading, spacing: PulseSpacing.sm) {
                        Text("Device health")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundStyle(PulseTheme.textPrimary)

                        Text(overviewMessage)
                            .font(.subheadline)
                            .foregroundStyle(PulseTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)

                        NavigationLink(destination: AutoRunTestsView(engine: engine)) {
                            PulseButtonLabel(title: isIPad ? "Run diagnostics" : "Run all tests", icon: "play.fill")
                        }
                        .buttonStyle(PulsePrimaryButtonStyle())
                        .frame(maxWidth: 220)
                        .accessibilityIdentifier("runAllTestsButton")
                    }

                    Spacer(minLength: 0)

                    PulseProgressRing(
                        progress: completionProgress,
                        label: "\(Int(completionProgress * 100))%",
                        caption: "complete",
                        tint: completionTint
                    )
                    .frame(width: 112, height: 112)
                }
            }
        }
    }

    private var metricsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
            spacing: PulseSpacing.sm
        ) {
            PulseMetricCard(title: "Total", value: engine.tests.count, icon: "square.grid.2x2", tint: PulseTheme.accent)
            PulseMetricCard(title: "Passed", value: passedCount, icon: "checkmark.circle.fill", tint: PulseTheme.success)
            PulseMetricCard(title: "Needs attention", value: failedCount, icon: "exclamationmark.circle.fill", tint: failedCount > 0 ? PulseTheme.failure : PulseTheme.textSecondary)
        }
        .padding(PulseSpacing.lg)
        .background(PulseTheme.surfaceMuted)
        .overlay {
            RoundedRectangle(cornerRadius: PulseRadius.card, style: .continuous)
                .stroke(PulseTheme.divider, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: PulseRadius.card, style: .continuous))
    }

    private var categoryFilter: some View {
        VStack(alignment: .leading, spacing: PulseSpacing.sm) {
            Text("Browse diagnostics")
                .font(.headline)
                .foregroundStyle(PulseTheme.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: PulseSpacing.sm) {
                    CategoryPill(
                        title: "All tests",
                        icon: "square.grid.2x2",
                        count: engine.tests.count,
                        isSelected: selectedCategory == nil
                    ) {
                        withAnimation(.easeOut(duration: 0.2)) { selectedCategory = nil }
                    }

                    ForEach(TestCategory.allCases, id: \.self) { category in
                        CategoryPill(
                            title: category.rawValue,
                            icon: category.pulseIcon,
                            count: engine.testsByCategory(category).count,
                            isSelected: selectedCategory == category
                        ) {
                            withAnimation(.easeOut(duration: 0.2)) { selectedCategory = category }
                        }
                        .accessibilityIdentifier("category_\(category.rawValue)")
                    }
                }
                .padding(.leading, PulseSpacing.xs)
                .padding(.trailing, PulseSpacing.lg)
            }
            .padding(.horizontal, -PulseSpacing.lg)
        }
    }

    private var testList: some View {
        VStack(alignment: .leading, spacing: PulseSpacing.sm) {
            HStack(alignment: .firstTextBaseline) {
                Text(selectedCategory?.rawValue ?? "All diagnostics")
                    .font(.headline)
                    .foregroundStyle(PulseTheme.textPrimary)
                Spacer()
                Text("\(visibleTests.count)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(PulseTheme.textSecondary)
            }

            if visibleTests.isEmpty {
                PulseCard {
                    VStack(spacing: PulseSpacing.sm) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(PulseTheme.success)
                        Text("No diagnostics in this category")
                            .font(.headline)
                            .foregroundStyle(PulseTheme.textPrimary)
                        Text("Choose another category to continue.")
                            .font(.subheadline)
                            .foregroundStyle(PulseTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                }
            } else {
                LazyVStack(spacing: PulseSpacing.sm) {
                    ForEach(visibleTests, id: \.id) { test in
                        NavigationLink(destination: TestDetailView(test: test)) {
                            ModernTestCard(test: test)
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("test_\(test.id)")
                    }
                }
            }
        }
    }

    private var passedCount: Int {
        engine.tests.filter { $0.status == .passed }.count
    }

    private var failedCount: Int {
        engine.tests.filter { $0.status == .failed }.count
    }

    private var completionTint: Color {
        if failedCount > 0 { return PulseTheme.failure }
        if completionProgress == 1 { return PulseTheme.success }
        return PulseTheme.accent
    }

    private var overviewMessage: String {
        if failedCount > 0 {
            return "\(failedCount) diagnostic\(failedCount == 1 ? "" : "s") need\(failedCount == 1 ? "s" : "") your attention."
        }
        if engine.completedCount == 0 {
            return "Run a diagnostic sweep to check your device hardware."
        }
        if engine.completedCount == engine.tests.count {
            return "Your diagnostic sweep is complete. Review the results below."
        }
        return "\(engine.tests.count - engine.completedCount) diagnostics are ready to run."
    }
}

struct CategoryPill: View {
    let title: String
    let icon: String
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: PulseSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .bold))
                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                Text("\(count)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(isSelected ? Color.white.opacity(0.18) : PulseTheme.surfaceRaised)
                    .clipShape(Capsule())
            }
            .foregroundStyle(isSelected ? PulseTheme.background : PulseTheme.textSecondary)
            .padding(.horizontal, PulseSpacing.sm)
            .padding(.vertical, PulseSpacing.sm)
            .background(isSelected ? PulseTheme.accent : PulseTheme.surface)
            .overlay {
                Capsule().stroke(isSelected ? Color.clear : PulseTheme.divider, lineWidth: 1)
            }
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(title), \(count) tests")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

struct ModernTestCard: View {
    @ObservedObject var test: BaseDiagnosticTest

    var body: some View {
        PulseCard {
            HStack(spacing: PulseSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(statusColor.opacity(0.13))
                        .frame(width: 48, height: 48)

                    Image(systemName: statusIcon)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(statusColor)
                }

                VStack(alignment: .leading, spacing: PulseSpacing.xs) {
                    HStack(spacing: PulseSpacing.xs) {
                        Text(test.title)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(PulseTheme.textPrimary)

                        if !test.isSupported {
                            Text("Unavailable")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(PulseTheme.warning)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 3)
                                .background(PulseTheme.warning.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }

                    Text(test.description)
                        .font(.subheadline)
                        .foregroundStyle(PulseTheme.textSecondary)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                VStack(alignment: .trailing, spacing: PulseSpacing.sm) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(PulseTheme.textSecondary)
                    PulseStatusBadge(status: test.status)
                }
            }
        }
        .contentShape(Rectangle())
    }

    private var statusColor: Color {
        switch test.status {
        case .passed: return PulseTheme.success
        case .failed: return PulseTheme.failure
        case .skipped: return PulseTheme.warning
        case .running: return PulseTheme.accent
        case .notStarted: return PulseTheme.unsupported
        }
    }

    private var statusIcon: String {
        switch test.status {
        case .passed: return "checkmark.circle.fill"
        case .failed: return "exclamationmark.circle.fill"
        case .skipped: return "minus.circle.fill"
        case .running: return "dot.radiowaves.left.and.right"
        case .notStarted: return "circle.dashed"
        }
    }
}
