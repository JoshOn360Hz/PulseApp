import XCTest
@testable import Pulse

@MainActor
final class DiagnosticModelTests: XCTestCase {
    func testPassedResultStoresMetadataAndStatus() {
        let test = DeterministicDiagnosticTest(id: "fixture-pass")

        test.markPassed(metadata: ["source": "unit-test"])

        XCTAssertEqual(test.status, .passed)
        XCTAssertEqual(test.result?.testId, "fixture-pass")
        XCTAssertEqual(test.result?.metadata["source"], "unit-test")
        XCTAssertNil(test.result?.failureReason)
    }

    func testFailedResultStoresReason() {
        let test = DeterministicDiagnosticTest(id: "fixture-fail")

        test.markFailed(reason: "Fixture reported a failed signal")

        XCTAssertEqual(test.status, .failed)
        XCTAssertEqual(test.result?.failureReason, "Fixture reported a failed signal")
    }

    func testResetClearsStatusAndResult() {
        let test = DeterministicDiagnosticTest(id: "fixture-reset")
        test.markPassed()

        test.reset()

        XCTAssertEqual(test.status, .notStarted)
        XCTAssertNil(test.result)
    }
}

@MainActor
final class DeterministicDiagnosticTest: BaseDiagnosticTest {
    private let resultStatus: TestStatus

    init(
        id: String,
        category: TestCategory = .systemConnectivity,
        isSupported: Bool = true,
        resultStatus: TestStatus = .passed
    ) {
        self.resultStatus = resultStatus
        super.init(
            id: id,
            title: "Fixture \(id)",
            description: "Deterministic fixture for automated tests",
            category: category,
            isSupported: isSupported
        )
    }

    override func run() async throws {
        if resultStatus == .passed {
            markPassed(metadata: ["fixture": "true"])
        } else {
            markFailed(reason: "Fixture failure")
        }
    }
}
