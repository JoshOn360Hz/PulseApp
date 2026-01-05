import SwiftUI

// Supporting Views for Reports

struct ResultStat: View {
    let label: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text("\(count)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct DeviceInfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
        }
    }
}

struct CategoryResultsCard: View {
    let category: TestCategory
    let results: [TestResult]
    let engine: DiagnosticEngine
    
    var passCount: Int {
        results.filter { $0.status == .passed }.count
    }
    
    var failCount: Int {
        results.filter { $0.status == .failed }.count
    }
    
    var icon: String {
        switch category {
        case .inputInteraction: return "hand.tap"
        case .display: return "display"
        case .cameraMedia: return "camera"
        case .sensors: return "sensor"
        case .biometrics: return "faceid"
        case .systemConnectivity: return "cpu"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.blue)
                
                Text(category.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                
                Spacer()
                
                HStack(spacing: 12) {
                    if passCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                            Text("\(passCount)")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.green)
                    }
                    
                    if failCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12))
                            Text("\(failCount)")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            
            Divider()
            
            VStack(spacing: 8) {
                ForEach(results) { result in
                    if let test = engine.tests.first(where: { $0.id == result.testId }) {
                        HStack(spacing: 12) {
                            Image(systemName: result.status == .passed ? "checkmark.circle.fill" :
                                               result.status == .failed ? "xmark.circle.fill" :
                                               "minus.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(result.status == .passed ? .green :
                                               result.status == .failed ? .red : .orange)
                            
                            Text(test.title)
                                .font(.system(size: 14))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
