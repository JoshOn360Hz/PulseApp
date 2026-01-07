import SwiftUI

struct TestsTabView: View {
    @ObservedObject var engine: DiagnosticEngine
    @State private var selectedCategory: TestCategory = .inputInteraction
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var isIPad: Bool {
        horizontalSizeClass == .regular && UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var contentView: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.1),
                    Color.cyan.opacity(0.05)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Pulse")
                                .font(.system(size: 34, weight: .bold))
                        }
                        Spacer()
                        
                        // Reset button
                        Button(action: {
                            engine.resetAllTests()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 13, weight: .semibold))
                                Text("Reset")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    colors: [Color.orange, Color.orange.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(20)
                            .shadow(color: Color.orange.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        
                        // Run all button (hidden on iPad)
                        if !isIPad {
                            NavigationLink(destination: AutoRunTestsView(engine: engine)) {
                                HStack(spacing: 6) {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 13, weight: .semibold))
                                    Text("Run All")
                                        .font(.system(size: 15, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    LinearGradient(
                                        colors: [Color.blue, Color.blue.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .cornerRadius(20)
                                .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // Stats Cards
                    HStack(spacing: 12) {
                        CompactStatCard(
                            title: "Total",
                            value: engine.tests.count,
                            icon: "square.grid.2x2",
                            color: .blue
                        )
                        
                        CompactStatCard(
                            title: "Passed",
                            value: engine.tests.filter { $0.status == .passed }.count,
                            icon: "checkmark.circle.fill",
                            color: .green
                        )
                        
                        CompactStatCard(
                            title: "Failed",
                            value: engine.tests.filter { $0.status == .failed }.count,
                            icon: "xmark.circle.fill",
                            color: .red
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
                .background(Color(.systemBackground))
                
                // Category pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(TestCategory.allCases, id: \.self) { category in
                            CategoryPill(
                                category: category,
                                isSelected: selectedCategory == category,
                                testCount: engine.testsByCategory(category).count
                            )
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedCategory = category
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
                .background(Color(.systemGray6).opacity(0.5))
                
                // Test Cards
                ScrollView {
                    LazyVStack(spacing: 12) {
                        let tests = engine.testsByCategory(selectedCategory)
                        
                        if tests.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "tray")
                                    .font(.system(size: 48))
                                    .foregroundColor(.secondary)
                                Text("No tests in this category")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 60)
                        } else {
                            ForEach(tests, id: \.id) { test in
                                NavigationLink(destination: TestDetailView(test: test)) {
                                    ModernTestCard(test: test, engine: engine)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationBarHidden(true)
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
}

// Supporting Views

struct CompactStatCard: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            Text("\(value)")
                .font(.system(size: 22, weight: .bold))
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct CategoryPill: View {
    let category: TestCategory
    let isSelected: Bool
    let testCount: Int
    
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
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
            Text(category.rawValue)
                .font(.system(size: 14, weight: .semibold))
            Text("\(testCount)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(isSelected ? Color.white.opacity(0.2) : Color(.systemGray5))
                .cornerRadius(8)
        }
        .foregroundColor(isSelected ? .white : .primary)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            isSelected ?
            LinearGradient(
                colors: [Color.blue, Color.blue.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ) :
            LinearGradient(
                colors: [Color(.systemBackground), Color(.systemBackground)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: isSelected ? Color.blue.opacity(0.3) : Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct ModernTestCard: View {
    let test: any DiagnosticTest
    @ObservedObject var engine: DiagnosticEngine
    
    var statusColor: Color {
        switch test.status {
        case .passed: return .green
        case .failed: return .red
        case .skipped: return .orange
        case .running: return .blue
        case .notStarted: return .gray
        }
    }
    
    var statusIcon: String {
        switch test.status {
        case .passed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        case .skipped: return "minus.circle.fill"
        case .running: return "arrow.clockwise.circle.fill"
        case .notStarted: return "circle"
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Status indicator
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: statusIcon)
                    .font(.system(size: 22))
                    .foregroundColor(statusColor)
            }
            
            // Test info
            VStack(alignment: .leading, spacing: 6) {
                Text(test.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(test.description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
