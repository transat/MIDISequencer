import XCTest
@testable import MIDISequencer

final class MIDISequencerTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(MIDISequencer().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
