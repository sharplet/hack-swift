import Hack
import XCTest

final class ParserTests: XCTestCase {
  var parser: Parser!
  var symbols: SymbolTable!

  override func setUp() {
    super.setUp()
    parser = Parser()
    symbols = SymbolTable()
  }

  override func tearDown() {
    parser = nil
    symbols = nil
    super.tearDown()
  }

  func testItIgnoresEmptyLines() throws {
    try parser.parse("", symbols: &symbols)
    XCTAssertEqual(parser.instructions, [])
  }

  func testItIgnoresWhitespaceOnlyLines() throws {
    try parser.parse("\t ", symbols: &symbols)
    XCTAssertEqual(parser.instructions, [])
  }

  func testItIgnoresCommentOnlyLines() throws {
    try parser.parse("// hello world", symbols: &symbols)
    XCTAssertEqual(parser.instructions, [])
  }

  func testItParsesAInstructions() throws {
    try parser.parse(" @1", symbols: &symbols)
    try parser.parse("@456", symbols: &symbols)
    try parser.parse("@foo", symbols: &symbols)
    try parser.parse("@foo//bar", symbols: &symbols)
    try parser.parse("@-1", symbols: &symbols)
    XCTAssertEqual(parser.instructions, [
      .a(.literal(1)),
      .a(.literal(456)),
      .a(.symbol("foo")),
      .a(.symbol("foo")),
      .a(.literal(-1)),
    ])
  }

  func testItParsesCComputations() throws {
    try parser.parse("0;JMP", symbols: &symbols)
    try parser.parse("A=1", symbols: &symbols)
    try parser.parse("M=-1", symbols: &symbols)
    try parser.parse("AD=M", symbols: &symbols)
    try parser.parse("DM=-D", symbols: &symbols)
    try parser.parse("!D;JEQ", symbols: &symbols)
    try parser.parse("M=D;JNE", symbols: &symbols)
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

  func testItAllocatesSymbolsForLabels() throws {
    try parser.parse("(FIRST)", symbols: &symbols)
    try parser.parse("@1", symbols: &symbols)
    try parser.parse("@2", symbols: &symbols)
    try parser.parse("(END)", symbols: &symbols)
    try parser.parse("@3", symbols: &symbols)
    try parser.parse("@4", symbols: &symbols)
    XCTAssertEqual(symbols["FIRST"], 0)
    XCTAssertEqual(symbols["END"], 2)
  }
}
