import SwiftUI

struct ResultsTabView: View {
    @ObservedObject var engine: DiagnosticEngine
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var isGeneratingReport = false
    @State private var exportError: String?

    private var report: DiagnosticReport {
        engine.generateReport()
    }

    private var passRate: Double {
        guard !report.results.isEmpty else { return 0 }
        return Double(report.passedTests.count) / Double(report.results.count)
    }

    private var completedCount: Int {
        report.passedTests.count + report.failedTests.count + report.skippedTests.count
    }

    var body: some View {
        NavigationStack {
            ZStack {
                PulseTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: PulseSpacing.xl) {
                        summaryCard
                        metrics
                        deviceCard
                        resultsByCategory
                        exportCard
                    }
                    .frame(maxWidth: PulseTheme.contentMaxWidth)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, PulseSpacing.lg)
                    .padding(.top, PulseSpacing.lg)
                    .padding(.bottom, PulseSpacing.xxl)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Results")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(PulseTheme.background, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showingShareSheet) {
                ActivityViewController(activityItems: shareItems)
            }
            .alert("Export failed", isPresented: exportFailureBinding) {
                Button("OK", role: .cancel) { exportError = nil }
            } message: {
                Text(exportError ?? "Pulse could not create the selected report.")
            }
            .overlay {
                if isGeneratingReport {
                    generatingOverlay
                }
            }
        }
    }

    private var summaryCard: some View {
        PulseCard {
            HStack(spacing: PulseSpacing.xl) {
                PulseProgressRing(
                    progress: passRate,
                    label: report.results.isEmpty ? "—" : "\(Int(passRate * 100))%",
                    caption: "pass rate",
                    tint: summaryTint
                )
                .frame(width: 132, height: 132)

                VStack(alignment: .leading, spacing: PulseSpacing.sm) {
                    Text(summaryTitle)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(PulseTheme.textPrimary)

                    Text(summaryMessage)
                        .font(.subheadline)
                        .foregroundStyle(PulseTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    Label(formattedDate(report.timestamp), systemImage: "clock")
                        .font(.caption)
                        .foregroundStyle(PulseTheme.textSecondary)
                }
            }
        }
    }

    private var metrics: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
            spacing: PulseSpacing.sm
        ) {
            PulseMetricCard(title: "Completed", value: completedCount, icon: "checkmark.circle", tint: PulseTheme.accent)
            PulseMetricCard(title: "Passed", value: report.passedTests.count, icon: "checkmark.circle.fill", tint: PulseTheme.success)
            PulseMetricCard(title: "Failed", value: report.failedTests.count, icon: "exclamationmark.circle.fill", tint: PulseTheme.failure)
            PulseMetricCard(title: "Skipped", value: report.skippedTests.count, icon: "minus.circle.fill", tint: PulseTheme.warning)
        }
        .padding(PulseSpacing.lg)
        .background(PulseTheme.surfaceMuted)
        .overlay {
            RoundedRectangle(cornerRadius: PulseRadius.card, style: .continuous)
                .stroke(PulseTheme.divider, lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: PulseRadius.card, style: .continuous))
    }

    private var deviceCard: some View {
        PulseCard {
            VStack(alignment: .leading, spacing: PulseSpacing.lg) {
                PulseSectionHeader(
                    icon: "iphone",
                    title: "Device snapshot",
                    subtitle: "Captured when this report was generated"
                )

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: PulseSpacing.md) {
                    ReportFact(label: "Model", value: report.deviceInfo.model, icon: "iphone")
                    ReportFact(label: "System", value: "\(report.deviceInfo.systemName) \(report.deviceInfo.systemVersion)", icon: "gear")
                    ReportFact(label: "Battery", value: "\(Int(report.deviceInfo.batteryLevel * 100))%", icon: "battery.75")
                    ReportFact(label: "Storage free", value: report.deviceInfo.availableStorage, icon: "internaldrive")
                    ReportFact(label: "Screen", value: report.deviceInfo.screenResolution, icon: "display")
                    ReportFact(label: "Memory", value: report.deviceInfo.totalMemory, icon: "memorychip")
                }
            }
        }
    }

    private var resultsByCategory: some View {
        VStack(alignment: .leading, spacing: PulseSpacing.sm) {
            PulseSectionHeader(
                icon: "list.bullet.clipboard",
                title: "Diagnostic results",
                subtitle: report.results.isEmpty ? "Run a test to start your report" : "Grouped by hardware area"
            )

            if report.results.isEmpty {
                PulseCard {
                    VStack(spacing: PulseSpacing.sm) {
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(PulseTheme.accent)
                        Text("No results yet")
                            .font(.headline)
                            .foregroundStyle(PulseTheme.textPrimary)
                        Text("Your completed diagnostics will appear here.")
                            .font(.subheadline)
                            .foregroundStyle(PulseTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                }
            } else {
                ForEach(TestCategory.allCases, id: \.self) { category in
                    let categoryResults = report.results.filter { result in
                        engine.tests.first(where: { $0.id == result.testId })?.category == category
                    }

                    if !categoryResults.isEmpty {
                        CategoryResultsCard(category: category, results: categoryResults, engine: engine)
                    }
                }
            }
        }
    }

    private var exportCard: some View {
        PulseCard {
            VStack(alignment: .leading, spacing: PulseSpacing.md) {
                PulseSectionHeader(
                    icon: "square.and.arrow.up",
                    title: "Share report",
                    subtitle: "Export the diagnostics for support or your records"
                )

                HStack(spacing: PulseSpacing.sm) {
                    Button(action: exportPDF) {
                        PulseButtonLabel(title: "PDF", icon: "doc.richtext")
                    }
                    .buttonStyle(PulsePrimaryButtonStyle())
                    .accessibilityIdentifier("exportPDFButton")

                    Button(action: exportJSON) {
                        PulseButtonLabel(title: "JSON", icon: "curlybraces")
                    }
                    .buttonStyle(PulseSecondaryButtonStyle())
                    .accessibilityIdentifier("exportJSONButton")
                }
            }
        }
    }

    private var generatingOverlay: some View {
        ZStack {
            Color.black.opacity(0.62).ignoresSafeArea()

            VStack(spacing: PulseSpacing.md) {
                ProgressView()
                    .tint(PulseTheme.accent)
                    .scaleEffect(1.2)
                Text("Preparing report")
                    .font(.headline)
                    .foregroundStyle(PulseTheme.textPrimary)
                Text("Collecting your local diagnostic results…")
                    .font(.caption)
                    .foregroundStyle(PulseTheme.textSecondary)
            }
            .padding(PulseSpacing.xxl)
            .background(PulseTheme.surfaceRaised)
            .clipShape(RoundedRectangle(cornerRadius: PulseRadius.card, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: PulseRadius.card, style: .continuous)
                    .stroke(PulseTheme.divider, lineWidth: 1)
            }
        }
    }

    private var summaryTitle: String {
        if report.results.isEmpty { return "Ready when you are" }
        if report.failedTests.isEmpty { return "Looking good" }
        return "Needs attention"
    }

    private var summaryMessage: String {
        if report.results.isEmpty { return "Run a diagnostic to check your device hardware." }
        if report.failedTests.isEmpty { return "No failed diagnostics in this report." }
        return "Review the failed diagnostics and share this report if you need support."
    }

    private var summaryTint: Color {
        if report.results.isEmpty { return PulseTheme.accent }
        return report.failedTests.isEmpty ? PulseTheme.success : PulseTheme.failure
    }

    private var exportFailureBinding: Binding<Bool> {
        Binding(
            get: { exportError != nil },
            set: { if !$0 { exportError = nil } }
        )
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func exportPDF() {
        export({ ReportExporter.generatePDF(from: report) }, fileExtension: "pdf")
    }

    private func exportJSON() {
        export({ ReportExporter.generateJSON(from: report) }, fileExtension: "json")
    }

    private func export(_ generator: @escaping () -> Data?, fileExtension: String) {
        guard !isGeneratingReport else { return }
        isGeneratingReport = true
        let currentReport = report

        Task {
            let data = generator()
            let fileName = "Pulse_Report_\(Int(currentReport.timestamp.timeIntervalSince1970)).\(fileExtension)"
            let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

            do {
                guard let data else { throw CocoaError(.fileWriteUnknown) }
                try data.write(to: fileURL, options: .atomic)

                await MainActor.run {
                    isGeneratingReport = false
                    shareItems = [fileURL]
                    showingShareSheet = true
                }
            } catch {
                await MainActor.run {
                    isGeneratingReport = false
                    exportError = error.localizedDescription
                }
            }
        }
    }
}
