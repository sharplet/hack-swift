public struct Parser {
  public private(set) var instructions: [Instruction] = []

  public init() {}

  public mutating func parse(_ line: String) throws {
    guard var line = line.drop(while: { $0.isWhitespace }).nonEmpty else {
      return
    }

    if line.eat("@") {
      guard let value = line.prefix(while: isIdentifier).nonEmpty else {
        throw ParserError.aInstructionMissingIdentifier
      }
      instructions.append(.a(String(value)))
    } else {
      throw ParserError.invalidInstruction(String(line))
    }
  }

  private func isIdentifier(_ character: Character) -> Bool {
    character.isLetter || character.isNumber
  }
}

extension Parser {
  public enum Instruction: Equatable {
    case a(String)
  }
}

extension Parser.Instruction: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .a(value):
      return "a(\(value))"
    }
  }
}
