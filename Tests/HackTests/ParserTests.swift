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
    try parser.parse("0;JMP")
    try parser.parse("A=1")
    try parser.parse("M=-1")
    try parser.parse("AD=M")
    try parser.parse("DM=-D")
    try parser.parse("!D;JEQ")
    try parser.parse("M=D;JNE")
    print(parser.instructions)
    XCTAssertEqual(parser.instructions, [
      .c(comp: .zero, jump: .jmp),
      .c(dest: .a, comp: .one),
      .c(dest: .m, comp: .minusOne),
      .c(dest: .ad, comp: .m),
      .c(dest: .dm, comp: .minusD),
      .c(comp: .notD, jump: .jeq),
      .c(dest: .m, comp: .d, jump: .jne),
    ])
  }
}
