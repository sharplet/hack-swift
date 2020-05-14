import Hack
import XCTest

final class ParserTests: XCTestCase {
  var parser: Parser!

  override func setUp() {
    super.setUp()
    parser = Parser()
  }

  override func tearDown() {
    parser = nil
    super.tearDown()
  }

  func testItIgnoresEmptyLines() throws {
    try parser.parse("")
    XCTAssertEqual(parser.instructions, [])
  }

  func testItIgnoresWhitespaceOnlyLines() throws {
    try parser.parse("\t ")
    XCTAssertEqual(parser.instructions, [])
  }

  func testItParsesAInstructions() throws {
    try parser.parse(" @1")
    try parser.parse("@456")
    try parser.parse("@foo")
    try parser.parse("@foo//bar")
    try parser.parse("@-1")
    XCTAssertEqual(parser.instructions, [
      .a(.literal(1)),
      .a(.literal(456)),
      .a(.symbol("foo")),
      .a(.symbol("foo")),
      .a(.literal(-1)),
    ])
  }

  func testItParsesCComputations() throws {
    try parser.parse("0")
    try parser.parse("1")
    try parser.parse("-1")
    try parser.parse("D")
    try parser.parse("-D")
    try parser.parse("!D")
    try parser.parse("A")
    try parser.parse("-A")
    try parser.parse("!A")
    try parser.parse("D+1")
    try parser.parse("1+D")
    try parser.parse("A+1")
    try parser.parse("1+A")
    try parser.parse("D-1")
    try parser.parse("A-1")
    try parser.parse("D+A")
    try parser.parse("A+D")
    try parser.parse("D-A")
    try parser.parse("A-D")
    try parser.parse("D&A")
    try parser.parse("A&D")
    try parser.parse("D|A")
    try parser.parse("A|D")

    let expected = Parser.C.Computation.allCases.map { comp in
      Parser.Instruction.c(comp: comp)
    }

    XCTAssertEqual(parser.instructions, expected)
  }
}
