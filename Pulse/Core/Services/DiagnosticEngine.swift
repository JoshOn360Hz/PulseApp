import Foundation
import Combine

// Diagnostic Engine
@MainActor
class DiagnosticEngine: ObservableObject {
    static let shared = DiagnosticEngine()
    
    @Published var tests: [any DiagnosticTest] = []
    @Published var currentTest: (any DiagnosticTest)?
    @Published var isRunning = false
    
    var completedCount: Int {
        tests.filter { $0.status == .passed || $0.status == .failed || $0.status == .skipped }.count
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadTests()
    }
    
    private func loadTests() {
        tests = [
            // dynamically load 
        ]
    }
    
    func addTest(_ test: any DiagnosticTest) {
        tests.append(test)
        
        // Subscribe to test changes to trigger engine updates
        if let observableTest = test as? (any ObservableObject) {
            let testPublisher = (observableTest.objectWillChange as any Publisher) as! ObservableObjectPublisher
            testPublisher.sink { [weak self] _ in
                Task { @MainActor in
                    self?.objectWillChange.send()
                }
            }.store(in: &cancellables)
        }
    }
    
    func runTest(_ test: any DiagnosticTest) async {
        guard test.isSupported else {
            test.markSkipped(reason: "Not supported on this device")
            return
        }
        
        currentTest = test
        test.status = .running
        
        do {
            try await test.run()
        } catch {
            test.markFailed(reason: error.localizedDescription, metadata: [:])
        }
    }
    
    func runAllTests() async {
        isRunning = true
        
        // Reset all tests to start from scratch
        resetAllTests()
        
        for test in tests where test.isSupported {
            await runTest(test)
        }
        
        isRunning = false
        currentTest = nil
    }
    
    func resetAllTests() {
        tests.forEach { $0.reset() }
        currentTest = nil
    }
    
    func generateReport() -> DiagnosticReport {
        let results = tests.compactMap { $0.result }
        return DiagnosticReport(results: results)
    }
    
    func testsByCategory(_ category: TestCategory) -> [any DiagnosticTest] {
        tests.filter { $0.category == category }
    }
}
