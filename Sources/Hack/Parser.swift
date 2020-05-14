public struct Parser {
  public private(set) var instructions: [Instruction] = []

  public init() {}

  public mutating func parse(_ line: String) throws {
    guard var line = line.drop(while: { $0.isWhitespace }).nonEmpty else {
      return
    }

    if line.eat("@") {
      guard let value = line.prefix(while: \.isAValue).nonEmpty else {
        throw ParserError.aInstructionMissingIdentifier
      }
      if let value = Int(value) {
        instructions.append(.a(.literal(value)))
      } else {
        let name = String(value)
        instructions.append(.a(.symbol(name)))
      }
    } else if let comp = line.eat(C.Computation.self) {
      instructions.append(.c(comp: comp))
    } else {
      throw ParserError.invalidInstruction(String(line))
    }
  }
}

private extension Character {
  var isAValue: Bool {
    self == "-" || self == "_"
      || isLetter
      || isNumber
  }
}

extension Parser {
  public enum A: Equatable {
    case literal(Int)
    case symbol(String)
  }

  public enum C {
    public enum Computation: String, Equatable, CaseIterable {
      case zero = "0"
      case one = "1"
      case minusOne = "-1"
      case d = "D"
      case minusD = "-D"
      case notD = "!D"
      case a = "A"
      case minusA = "-A"
      case notA = "!A"
      case dPlusOne = "D+1", onePlusD = "1+D"
      case aPlusOne = "A+1", onePlusA = "1+A"
      case dMinusOne = "D-1"
      case aMinusOne = "A-1"
      case dPlusA = "D+A", aPlusD = "A+D"
      case dMinusA = "D-A"
      case aMinusD = "A-D"
      case dAndA = "D&A", aAndD = "A&D"
      case dOrA = "D|A", aOrD = "A|D"
    }

    public enum Destination: Equatable {
    }

    public enum Jump: Equatable {
    }
  }

  public enum Instruction: Equatable {
    case a(A)
    case c(dest: C.Destination? = nil, comp: C.Computation, jump: C.Jump? = nil)
  }
}

extension Parser.Instruction: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .a(.literal(value)):
      return "a(\(value))"
    case let .a(.symbol(symbol)):
      return "a(@\(symbol))"
    case let .c(_, comp, _):
      return comp.rawValue
    }
  }
}
