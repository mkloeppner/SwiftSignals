import XCTest
@testable import Signals

final class SignalsTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Signals().text, "Hello, World!")
    }
}
