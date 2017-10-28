import XCTest
@testable import protobuf_swift_generator_utils

class protobuf_swift_generator_utilsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(protobuf_swift_generator_utils().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
