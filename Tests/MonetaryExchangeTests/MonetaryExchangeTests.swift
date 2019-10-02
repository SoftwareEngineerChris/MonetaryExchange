import XCTest
@testable import MonetaryExchange

final class MonetaryExchangeTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(MonetaryExchange().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
