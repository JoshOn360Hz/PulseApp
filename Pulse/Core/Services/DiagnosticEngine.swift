import Foundation
import Combine

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
    
    init(tests: [any DiagnosticTest] = []) {
        self.tests = tests
    }
    
    func addTest(_ test: any DiagnosticTest) {
        guard !tests.contains(where: { $0.id == test.id }) else { return }
        tests.append(test)
        
        // All production diagnostics inherit from BaseDiagnosticTest. Observe the
        // concrete publisher so SwiftUI refreshes list rows when hardware state changes.
        if let observableTest = test as? BaseDiagnosticTest {
            observableTest.objectWillChange
                .sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
                .store(in: &cancellables)
        }
    }
    
    func runTest(_ test: any DiagnosticTest) async {
        guard test.isSupported else {
            test.markSkipped(reason: "Not supported on this device")
            return
        }
        
        currentTest = test
        test.status = .running
        
        defer {
            if currentTest?.id == test.id {
                currentTest = nil
            }
        }

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
        
        for test in tests {
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
