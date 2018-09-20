
import XCTest
@testable import JSONFragmentDecoding

func XCTAssertEqual(
  _ expected: Any.Type, _ actual: Any.Type,
  file: StaticString = #file, line: UInt = #line) {
  XCTAssert(
    expected == actual, "incorrect type \(actual), expected \(expected)",
    file: file, line: line
  )
}

final class JSONFragmentDecodingTests : XCTestCase {

  func testFragmentDecoding() throws {

    XCTAssertEqual(10, try JSONDecoder()
      .decode(Int.self, from: Data("10".utf8), allowFragments: true))

    XCTAssertEqual("10", try JSONDecoder()
      .decode(String.self, from: Data("\"10\"".utf8), allowFragments: true))
  }

  func testExoticFragmentDecoding() throws {

    class C : Decodable {
      var i: Int
      required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.i = try container.decode(Int.self)
      }
    }
    class D : C {}

    let metatype: C.Type = D.self
    let data = "10".data(using: .utf32BigEndian)!
    let decoded = try JSONDecoder()
      .decode(metatype, from: data, allowFragments: true)

    XCTAssertEqual(D.self, type(of: decoded))
    XCTAssertEqual(10, decoded.i)
  }

  func testFloatStrategyDecoding() throws {
    let decoder = JSONDecoder()
    decoder.nonConformingFloatDecodingStrategy = .convertFromString(
      positiveInfinity: "inf", negativeInfinity: "-inf", nan: "nan"
    )

    let decodedInf = try decoder
      .decode(Double.self, from: Data("\"inf\"".utf8), allowFragments: true)
    XCTAssertEqual(.infinity, decodedInf)

    let decodedNegInf = try decoder
      .decode(Double.self, from: Data("\"-inf\"".utf8), allowFragments: true)
    XCTAssertEqual(-.infinity, decodedNegInf)

    let decodedNan = try decoder
      .decode(Double.self, from: Data("\"nan\"".utf8), allowFragments: true)
    XCTAssert(decodedNan.isNaN)
  }

  static var allTests = [
    ("testFragmentDecoding", testFragmentDecoding),
    ("testExoticFragmentDecoding", testExoticFragmentDecoding)
  ]
}
