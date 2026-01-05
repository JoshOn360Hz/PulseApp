import SwiftUI

struct ReportSceneView: View {
    @ObservedObject var engine: DiagnosticEngine
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var report: DiagnosticReport?
    
    var body: some View {
        ScrollView {
            if let report = report {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 10) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("Diagnostic Report")
                            .font(.title)
                            .bold()
                        
                        Text(formattedDate(report.timestamp))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // Device Info Card
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Device Information")
                            .font(.headline)
                        
                        Divider()
                        
                        InfoRow(label: "Model", value: report.deviceInfo.model)
                        InfoRow(label: "System", value: "\(report.deviceInfo.systemName) \(report.deviceInfo.systemVersion)")
                        InfoRow(label: "Device Name", value: report.deviceInfo.deviceName)
                        InfoRow(label: "Battery", value: "\(Int(report.deviceInfo.batteryLevel * 100))% (\(report.deviceInfo.batteryState))")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Summary Card
                    VStack(spacing: 15) {
                        Text("Test Summary")
                            .font(.headline)
                        
                        Divider()
                        
                        HStack(spacing: 20) {
                            SummaryItem(
                                label: "Total",
                                count: report.results.count,
                                color: .blue
                            )
                            
                            SummaryItem(
                                label: "Passed",
                                count: report.passedTests.count,
                                color: .green
                            )
                            
                            SummaryItem(
                                label: "Failed",
                                count: report.failedTests.count,
                                color: .red
                            )
                            
                            SummaryItem(
                                label: "Skipped",
                                count: report.skippedTests.count,
                                color: .orange
                            )
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    // Results List
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Test Results")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(report.results) { result in
                            ResultRow(result: result)
                                .padding(.horizontal)
                        }
                    }
                    
                    // Export Buttons
                    VStack(spacing: 15) {
                        Button(action: exportPDF) {
                            HStack {
                                Image(systemName: "doc.fill")
                                Text("Export as PDF")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        }
                        
                        Button(action: exportJSON) {
                            HStack {
                                Image(systemName: "curlybraces")
                                Text("Export as JSON")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            } else {
                ProgressView("Generating report...")
                    .padding()
            }
        }
        .navigationTitle("Report")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: shareItems)
        }
        .onAppear {
            if report == nil {
                report = engine.generateReport()
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func exportPDF() {
        guard let report = report else { return }
        if let pdfData = ReportExporter.generatePDF(from: report) {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("PulseDiagnosticReport.pdf")
            try? pdfData.write(to: tempURL)
            shareItems = [tempURL]
            showingShareSheet = true
        }
    }
    
    private func exportJSON() {
        guard let report = report else { return }
        if let jsonData = ReportExporter.generateJSON(from: report) {
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("PulseDiagnosticReport.json")
            try? jsonData.write(to: tempURL)
            shareItems = [tempURL]
            showingShareSheet = true
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
        .font(.subheadline)
    }
}

struct SummaryItem: View {
    let label: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text("\(count)")
                .font(.title2)
                .bold()
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct ResultRow: View {
    let result: TestResult
    
    var statusColor: Color {
        switch result.status {
        case .passed: return .green
        case .failed: return .red
        case .skipped: return .orange
        default: return .gray
        }
    }
    
    var statusIcon: String {
        switch result.status {
        case .passed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        case .skipped: return "minus.circle.fill"
        default: return "circle"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
                
                Text(result.testId.replacingOccurrences(of: "_", with: " ").capitalized)
                    .font(.headline)
                
                Spacer()
                
                Text(result.status.rawValue)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.2))
                    .foregroundColor(statusColor)
                    .cornerRadius(8)
            }
            
            if let reason = result.failureReason {
                Text(reason)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        
        // Exclude certain activity types if needed
        controller.excludedActivityTypes = [
            .assignToContact,
            .addToReadingList
        ]
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
