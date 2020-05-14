public struct Parser {
  public private(set) var instructions: [Instruction] = []

  public init() {}

  public mutating func parse(_ line: String, symbols: inout SymbolTable) throws {
    var line = Substring(line)

    if let comment = line.range(of: "//") {
      line.removeSubrange(comment.lowerBound...)
    }

    line.trim(where: \.isWhitespace)

    guard !line.isEmpty else { return }

    if line.eat("(") {
      guard let end = line.firstIndex(of: ")") else {
        throw ParserError.unclosedLabel(String(line))
      }

      let label = String(line[..<end])

      guard symbols[label] == nil else {
        throw ParserError.duplicateLabel(label)
      }

      symbols[label: label] = instructions.count
    } else if line.eat("@") {
      guard let value = line.prefix(while: \.isAValue).nonEmpty else {
        throw ParserError.aInstructionMissingIdentifier
      }
      if let value = Int(value) {
        instructions.append(.resolved(.a(value)))
      } else {
        let name = String(value)
        instructions.append(.symbolic(name))
      }
    } else {
      let assignment = line.firstIndex(of: "=")
      let jump = assignment.flatMap { line[$0...].firstIndex(of: ";") }
        ?? line.firstIndex(of: ";")
      let comp = assignment.map(line.index(after:)) ?? line.startIndex

      switch (assignment, jump) {
      case let (assignment?, jump?):
        guard let dest = line[..<assignment].nonEmpty.flatMap(Hack.Instruction.C.Destination.init),
          let comp = line[comp..<jump].nonEmpty.flatMap(Hack.Instruction.C.Computation.init),
          let jump = line[line.index(after: jump)...].nonEmpty.flatMap(Hack.Instruction.C.Jump.init)
          else { throw ParserError.invalidInstruction(String(line)) }
        instructions.append(.resolved(.c(dest: dest, comp: comp, jump: jump)))

      case let (assignment?, nil):
        guard let dest = line[..<assignment].nonEmpty.flatMap(Hack.Instruction.C.Destination.init),
          let comp = line[comp...].nonEmpty.flatMap(Hack.Instruction.C.Computation.init)
          else { throw ParserError.invalidInstruction(String(line)) }
        instructions.append(.resolved(.c(dest: dest, comp: comp)))

      case let (nil, jump?):
        guard let comp = line[comp..<jump].nonEmpty.flatMap(Hack.Instruction.C.Computation.init),
          let jump = line[line.index(after: jump)...].nonEmpty.flatMap(Hack.Instruction.C.Jump.init)
          else { throw ParserError.invalidInstruction(String(line)) }
        instructions.append(.resolved(.c(comp: comp, jump: jump)))

      case (nil, nil):
        throw ParserError.invalidInstruction(String(line))
      }
    }
  }
}

private extension Character {
  var isAValue: Bool {
    self == "-" || self == "_"
      || isLetter
      || isNumber
  }

  var isCSeparator: Bool {
    self == "=" || self == ";"
  }
}

extension Parser {
  public enum Instruction: Equatable {
    case resolved(Hack.Instruction)
    case symbolic(String)
  }
}

extension Parser.Instruction: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .resolved(.a(value)):
      return "a(\(value))"

    case let .symbolic(symbol):
      return "a(@\(symbol))"

    case let .resolved(.c(dest, comp, jump)):
      var description = comp.rawValue
      if let dest = dest {
        description.insert(contentsOf: "\(dest.rawValue)=", at: description.startIndex)
      }
      if let jump = jump {
        description.append(";\(jump.rawValue)")
      }
      return description
    }
  }
}
