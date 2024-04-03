import Foundation
import XCTest

final class SonomaRegexBugTestSwift: XCTestCase {
  func testWordBoundaryNSRegularExpression() throws {
    let regex = try NSRegularExpression(pattern: "\\bname", options: [])
    let stringToMatch = "self.name"
    let range = regex.rangeOfFirstMatch(
      in: stringToMatch,
      options: [],
      range: NSRange(location: 0, length: stringToMatch.count))
    let expectedRange = NSRange(location: 5, length: 4)
    XCTAssertEqual(range, expectedRange)
  }

  func testWordBoundaryNSStringStringRangeOfString() throws {
    let stringToMatch = "self.name" as NSString
    let range = stringToMatch.range(
      of: "\\bname",
      options: .regularExpression)
    XCTAssertEqual(range, NSRange(location: 5, length: 4))
  }

  func testWordBoundarySwiftStringRangeOfString() throws {
    let stringToMatch = "self.name"
    let range = stringToMatch.range(
      of: "\\bname",
      options: .regularExpression)
    XCTAssertEqual(range, Range(NSRange(location: 5, length: 4), in: stringToMatch))
  }
}