import XCTest
@testable import Pulse

@MainActor
final class DiagnosticEngineTests: XCTestCase {
    func testAddTestIgnoresDuplicateIDs() {
        let first = DeterministicDiagnosticTest(id: "duplicate")
        let duplicate = DeterministicDiagnosticTest(id: "duplicate", category: .display)
        let engine = DiagnosticEngine(tests: [first])

        engine.addTest(duplicate)

        XCTAssertEqual(engine.tests.count, 1)
        XCTAssertEqual(engine.tests.first?.id, "duplicate")
    }

    func testCategoryFilteringReturnsOnlyMatchingTests() {
        let input = DeterministicDiagnosticTest(id: "input", category: .inputInteraction)
        let sensor = DeterministicDiagnosticTest(id: "sensor", category: .sensors)
        let engine = DiagnosticEngine(tests: [input, sensor])

        XCTAssertEqual(engine.testsByCategory(.inputInteraction).map(\.id), ["input"])
        XCTAssertEqual(engine.testsByCategory(.sensors).map(\.id), ["sensor"])
    }

    func testRunAllRecordsPassAndUnsupportedSkip() async {
        let passing = DeterministicDiagnosticTest(id: "passing")
        let unsupported = DeterministicDiagnosticTest(id: "unsupported", isSupported: false)
        let engine = DiagnosticEngine(tests: [passing, unsupported])

        await engine.runAllTests()

        XCTAssertEqual(passing.status, .passed)
        XCTAssertEqual(unsupported.status, .skipped)
        XCTAssertEqual(engine.completedCount, 2)
        XCTAssertFalse(engine.isRunning)
        XCTAssertNil(engine.currentTest)
    }

    func testRunTestPublishesCompletedResultAndClearsCurrentTest() async {
        let test = DeterministicDiagnosticTest(id: "single-run")
        let engine = DiagnosticEngine(tests: [test])

        await engine.runTest(test)

        XCTAssertEqual(test.status, .passed)
        XCTAssertNotNil(test.result)
        XCTAssertNil(engine.currentTest)
    }

    func testResetAllClearsEveryTest() async {
        let first = DeterministicDiagnosticTest(id: "first")
        let second = DeterministicDiagnosticTest(id: "second")
        let engine = DiagnosticEngine(tests: [first, second])

        await engine.runAllTests()
        engine.resetAllTests()

        XCTAssertTrue(engine.tests.allSatisfy { $0.status == .notStarted && $0.result == nil })
        XCTAssertEqual(engine.completedCount, 0)
    }
}
