import XCTest
@testable import ClosureBasedTableViewKit

final class ClosureBasedTableViewKitTests: XCTestCase {
    func testExample() {
        XCTAssert(ClosureBasedTableViewKit.kitVersion==1, "Correct Version")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
