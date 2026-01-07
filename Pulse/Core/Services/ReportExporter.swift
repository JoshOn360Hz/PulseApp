import PDFKit
import UIKit

class ReportExporter {
    
    static func generatePDF(from report: DiagnosticReport) -> Data? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Pulse Diagnostics",
            kCGPDFContextTitle: "Diagnostic Report"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11.0 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            var yPosition: CGFloat = 50
            
            // Title
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 24),
                .foregroundColor: UIColor.black
            ]
            let title = "Pulse Diagnostic Report"
            title.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: titleAttributes)
            yPosition += 40
            
            // Date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            
            let dateText = "Generated: \(dateFormatter.string(from: report.timestamp))"
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor.gray
            ]
            dateText.draw(at: CGPoint(x: 50, y: yPosition), withAttributes: textAttributes)
            yPosition += 30
            
            // Device Info
            let headerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.black
            ]
            
            "Device Information".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: headerAttributes)
            yPosition += 25
            
            let deviceLines = [
                "Model: \(report.deviceInfo.model)",
                "Identifier: \(report.deviceInfo.modelIdentifier)",
                "System: \(report.deviceInfo.systemName) \(report.deviceInfo.systemVersion)",
                "Device Name: \(report.deviceInfo.deviceName)",
                "Battery: \(Int(report.deviceInfo.batteryLevel * 100))% (\(report.deviceInfo.batteryState))",
                "",
                "Screen: \(report.deviceInfo.screenResolution) @ \(report.deviceInfo.screenScale)",
                "Storage: \(report.deviceInfo.availableStorage) / \(report.deviceInfo.totalStorage)",
                "Memory: \(report.deviceInfo.totalMemory)",
                "CPU Cores: \(report.deviceInfo.processorCount)",
                "Low Power Mode: \(report.deviceInfo.isLowPowerModeEnabled ? "Enabled" : "Disabled")",
                "Locale: \(report.deviceInfo.locale)",
                "Timezone: \(report.deviceInfo.timezone)"
            ]
            
            for line in deviceLines {
                if line.isEmpty {
                    yPosition += 10
                } else {
                    line.draw(at: CGPoint(x: 70, y: yPosition), withAttributes: textAttributes)
                    yPosition += 20
                }
            }
            yPosition += 20
            
            // Summary
            "Test Summary".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: headerAttributes)
            yPosition += 25
            
            let summaryLines = [
                "Total Tests: \(report.results.count)",
                "Passed: \(report.passedTests.count)",
                "Failed: \(report.failedTests.count)",
                "Skipped: \(report.skippedTests.count)"
            ]
            
            for line in summaryLines {
                line.draw(at: CGPoint(x: 70, y: yPosition), withAttributes: textAttributes)
                yPosition += 20
            }
            yPosition += 20
            
            // Test Results
            "Test Results".draw(at: CGPoint(x: 50, y: yPosition), withAttributes: headerAttributes)
            yPosition += 25
            
            for result in report.results {
                let statusColor: UIColor
                switch result.status {
                case .passed: statusColor = .systemGreen
                case .failed: statusColor = .systemRed
                case .skipped: statusColor = .systemOrange
                default: statusColor = .gray
                }
                
                let resultAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 11),
                    .foregroundColor: statusColor
                ]
                
                let resultText = "[\(result.status.rawValue)] \(result.testId)"
                resultText.draw(at: CGPoint(x: 70, y: yPosition), withAttributes: resultAttributes)
                yPosition += 18
                
                if let reason = result.failureReason {
                    let reasonText = "  → \(reason)"
                    let reasonAttributes: [NSAttributedString.Key: Any] = [
                        .font: UIFont.italicSystemFont(ofSize: 10),
                        .foregroundColor: UIColor.darkGray
                    ]
                    reasonText.draw(at: CGPoint(x: 90, y: yPosition), withAttributes: reasonAttributes)
                    yPosition += 18
                }
                
                if yPosition > pageHeight - 100 {
                    context.beginPage()
                    yPosition = 50
                }
            }
            
            // Footer
            let footer = "Generated by Pulse Diagnostics"
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.lightGray
            ]
            footer.draw(at: CGPoint(x: 50, y: pageHeight - 50), withAttributes: footerAttributes)
        }
        
        return data
    }
    
    static func generateJSON(from report: DiagnosticReport) -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        return try? encoder.encode(report)
    }
}
