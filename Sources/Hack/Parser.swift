public struct Parser {
  public private(set) var instructions: [Instruction] = []

  public init() {}

  public mutating func parse(_ line: String) throws {
    guard var line = line.drop(while: { $0.isWhitespace }).nonEmpty else {
      return
    }

    if line.eat("@") {
      guard let value = line.prefix(while: isAValue).nonEmpty else {
        throw ParserError.aInstructionMissingIdentifier
      }
      if let value = Int(value) {
        instructions.append(.aliteral(value))
      } else {
        instructions.append(.asymbol(String(value)))
      }
    } else {
      throw ParserError.invalidInstruction(String(line))
    }
  }

  private func isAValue(_ character: Character) -> Bool {
    character == "-"
      || character == "_"
      || character.isLetter
      || character.isNumber
  }
}

extension Parser {
  public enum Instruction: Equatable {
    case aliteral(Int)
    case asymbol(String)
  }
}

extension Parser.Instruction: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .aliteral(value):
      return "a(\(value))"
    case let .asymbol(symbol):
      return "a(@\(symbol))"
    }
  }
}
