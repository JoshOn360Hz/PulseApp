import SwiftUI

// Results Tab View (Used in HomeSceneView TabView)
struct ResultsTabView: View {
    @ObservedObject var engine: DiagnosticEngine
    @State private var showingShareSheet = false
    @State private var shareItems: [Any] = []
    @State private var isGeneratingReport = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var isIPad: Bool {
        horizontalSizeClass == .regular && UIDevice.current.userInterfaceIdiom == .pad
    }
    
    private var report: DiagnosticReport {
        engine.generateReport()
    }
    
    private var passRate: Double {
        let total = Double(report.results.count)
        guard total > 0 else { return 0 }
        return Double(report.passedTests.count) / total * 100
    }
    
    var contentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Results")
                                .font(.system(size: 34, weight: .bold))
                            Text(formattedDate(report.timestamp))
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }
                
                // Pass rate circle
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(Color(.systemGray5), lineWidth: 12)
                            .frame(width: 140, height: 140)
                        
                        Circle()
                            .trim(from: 0, to: passRate / 100)
                            .stroke(
                                LinearGradient(
                                    colors: passRate >= 80 ? [.green, .green.opacity(0.7)] :
                                        passRate >= 50 ? [.orange, .orange.opacity(0.7)] :
                                        [.red, .red.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .frame(width: 140, height: 140)
                            .rotationEffect(.degrees(-90))
                        
                        VStack(spacing: 4) {
                            Text("\(Int(passRate))%")
                                .font(.system(size: 36, weight: .bold))
                            Text("Pass Rate")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 10)
                    
                    // Summary stats
                    HStack(spacing: 20) {
                        ResultStat(
                            label: "Passed",
                            count: report.passedTests.count,
                            color: .green
                        )
                        
                        Divider()
                            .frame(height: 30)
                        
                        ResultStat(
                            label: "Failed",
                            count: report.failedTests.count,
                            color: .red
                        )
                        
                        Divider()
                            .frame(height: 30)
                        
                        ResultStat(
                            label: "Skipped",
                            count: report.skippedTests.count,
                            color: .orange
                        )
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 20)
                
                // Device info card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "iphone")
                            .font(.title3)
                            .foregroundColor(.blue)
                        Text("Device Information")
                            .font(.headline)
                    }
                    
                    // Basic Info Section
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Basic Information")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 4)
                        
                        VStack(spacing: 12) {
                            DeviceInfoRow(
                                icon: "iphone",
                                label: "Model",
                                value: report.deviceInfo.model
                            )
                            DeviceInfoRow(
                                icon: "number",
                                label: "Identifier",
                                value: report.deviceInfo.modelIdentifier
                            )
                            DeviceInfoRow(
                                icon: "gear",
                                label: "System",
                                value: "\(report.deviceInfo.systemName) \(report.deviceInfo.systemVersion)"
                            )
                            DeviceInfoRow(
                                icon: "battery.75",
                                label: "Battery",
                                value: "\(Int(report.deviceInfo.batteryLevel * 100))%"
                            )
                        }
                    }
                    
                    Divider()
                        .padding(.vertical, 4)
                    
                    // Hardware Specs Section
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hardware")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 4)
                        
                        VStack(spacing: 12) {
                            DeviceInfoRow(
                                icon: "display",
                                label: "Screen",
                                value: "\(report.deviceInfo.screenResolution) @ \(report.deviceInfo.screenScale)"
                            )
                            DeviceInfoRow(
                                icon: "internaldrive",
                                label: "Storage",
                                value: "\(report.deviceInfo.availableStorage) / \(report.deviceInfo.totalStorage)"
                            )
                            DeviceInfoRow(
                                icon: "memorychip",
                                label: "Memory",
                                value: report.deviceInfo.totalMemory
                            )
                            DeviceInfoRow(
                                icon: "cpu",
                                label: "CPU Cores",
                                value: "\(report.deviceInfo.processorCount)"
                            )
                            DeviceInfoRow(
                                icon: "bolt.badge.a",
                                label: "Low Power",
                                value: report.deviceInfo.isLowPowerModeEnabled ? "Enabled" : "Disabled"
                            )
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 20)
                
                // Test results by category
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "list.bullet.clipboard")
                            .font(.title3)
                            .foregroundColor(.blue)
                        Text("Test Results")
                            .font(.headline)
                    }
                    .padding(.horizontal, 20)
                    
                    ForEach(TestCategory.allCases, id: \.self) { category in
                        let categoryResults = report.results.filter { result in
                            engine.tests.first(where: { $0.id == result.testId })?.category == category
                        }
                        
                        if !categoryResults.isEmpty {
                            CategoryResultsCard(
                                category: category,
                                results: categoryResults,
                                engine: engine
                            )
                        }
                    }
                }
                .padding(.vertical, 10)
                
                // Export buttons
                VStack(spacing: 12) {
                    Button(action: exportPDF) {
                        HStack {
                            Image(systemName: "doc.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Export as PDF")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                    
                    Button(action: exportJSON) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Export as JSON")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarHidden(true)
        .sheet(isPresented: $showingShareSheet) {
            ActivityViewController(activityItems: shareItems)
        }
        .onChange(of: showingShareSheet) {
            // Clean up when sheet is dismissed
            if !showingShareSheet {
                shareItems = []
            }
        }
        .overlay {
            if isGeneratingReport {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.primary)
                        
                        Text("Generating Report...")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .padding(40)
                    .background(Material.regular)
                    .cornerRadius(20)
                    .shadow(radius: 20)
                }
            }
        }
    }
    
    var body: some View {
        Group {
            if isIPad {
                NavigationStack {
                    contentView
                }
            } else {
                NavigationView {
                    contentView
                }
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func exportPDF() {
        isGeneratingReport = true
        
        Task {
            let minimumDisplayTime = 0.8
            let currentReport = report
            
            // Run generation and minimum wait in parallel
            async let generationTask: (Data, URL)? = Task {
                guard let pdfData = await ReportExporter.generatePDF(from: currentReport) else {
                    return nil
                }
                
                let tempDir = FileManager.default.temporaryDirectory
                let fileName = "Pulse_Report_\(Date().timeIntervalSince1970).pdf"
                let fileURL = tempDir.appendingPathComponent(fileName)
                
                do {
                    try pdfData.write(to: fileURL)
                    return (pdfData, fileURL)
                } catch {
                    print("Error saving PDF: \(error)")
                    return nil
                }
            }.value
            
            async let minimumWait: Void = {
                try? await Task.sleep(nanoseconds: UInt64(minimumDisplayTime * 1_000_000_000))
            }()
            
            // Wait for both to complete
            _ = await minimumWait
            let result = await generationTask
            
            await MainActor.run {
                isGeneratingReport = false
                
                if let (_, fileURL) = result {
                    // Clear previous items first
                    shareItems = []
                    // Small delay to ensure state is clean
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        shareItems = [fileURL]
                        showingShareSheet = true
                    }
                } else {
                    print("Failed to generate PDF")
                }
            }
        }
    }
    
    private func exportJSON() {
        isGeneratingReport = true
        
        Task {
            let minimumDisplayTime = 0.8
            let currentReport = report
            
            // Run generation and minimum wait in parallel
            async let generationTask: (Data, URL)? = Task {
                guard let jsonData = await ReportExporter.generateJSON(from: currentReport) else {
                    return nil
                }
                
                let tempDir = FileManager.default.temporaryDirectory
                let fileName = "Pulse_Report_\(Date().timeIntervalSince1970).json"
                let fileURL = tempDir.appendingPathComponent(fileName)
                
                do {
                    try jsonData.write(to: fileURL)
                    return (jsonData, fileURL)
                } catch {
                    print("Error saving JSON: \(error)")
                    return nil
                }
            }.value
            
            async let minimumWait: Void = {
                try? await Task.sleep(nanoseconds: UInt64(minimumDisplayTime * 1_000_000_000))
            }()
            
            // Wait for both to complete
            _ = await minimumWait
            let result = await generationTask
            
            await MainActor.run {
                isGeneratingReport = false
                
                if let (_, fileURL) = result {
                    // Clear previous items first
                    shareItems = []
                    // Small delay to ensure state is clean
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        shareItems = [fileURL]
                        showingShareSheet = true
                    }
                } else {
                    print("Failed to generate JSON")
                }
            }
        }
    }
    
    
    // Supporting Views
    // (Moved to ReportComponents.swift)
    
}
