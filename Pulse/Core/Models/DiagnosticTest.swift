import Foundation
import Combine

enum TestStatus: String, Codable {
    case notStarted = "Not Started"
    case running = "Running"
    case passed = "PASS"
    case failed = "FAIL"
    case skipped = "SKIPPED"
}

enum TestCategory: String, Codable, CaseIterable {
    case inputInteraction = "Input & Interaction"
    case display = "Display"
    case cameraMedia = "Camera & Media"
    case sensors = "Sensors"
    case biometrics = "Biometrics"
    case systemConnectivity = "System & Connectivity"
}

struct TestResult: Codable, Identifiable {
    let id: UUID
    let testId: String
    let status: TestStatus
    let timestamp: Date
    let failureReason: String?
    let metadata: [String: String]
    
    init(testId: String, status: TestStatus, failureReason: String? = nil, metadata: [String: String] = [:]) {
        self.id = UUID()
        self.testId = testId
        self.status = status
        self.timestamp = Date()
        self.failureReason = failureReason
        self.metadata = metadata
    }
}

protocol DiagnosticTest: AnyObject, Identifiable {
    var id: String { get }
    var title: String { get }
    var description: String { get }
    var category: TestCategory { get }
    var isSupported: Bool { get }
    var status: TestStatus { get set }
    var result: TestResult? { get set }
    
    func run() async throws
    func reset()
    func markPassed(metadata: [String: String])
    func markFailed(reason: String, metadata: [String: String])
    func markSkipped(reason: String)
}

class BaseDiagnosticTest: DiagnosticTest, ObservableObject {
    let id: String
    let title: String
    let description: String
    let category: TestCategory
    var isSupported: Bool
    @Published var status: TestStatus = .notStarted
    @Published var result: TestResult?
    
    init(id: String, title: String, description: String, category: TestCategory, isSupported: Bool = true) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.isSupported = isSupported
    }
    
    func run() async throws {
        fatalError("Must be overridden by subclass")
    }
    
    func reset() {
        status = .notStarted
        result = nil
    }
    
    func markPassed(metadata: [String: String] = [:]) {
        status = .passed
        result = TestResult(testId: id, status: .passed, metadata: metadata)
    }
    
    func markFailed(reason: String, metadata: [String: String] = [:]) {
        status = .failed
        result = TestResult(testId: id, status: .failed, failureReason: reason, metadata: metadata)
    }
    
    func markSkipped(reason: String) {
        status = .skipped
        result = TestResult(testId: id, status: .skipped, failureReason: reason)
    }
}
