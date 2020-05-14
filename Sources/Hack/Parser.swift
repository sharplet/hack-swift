public struct Parser {
  public private(set) var instructions: [Instruction] = []

  public init() {}

  public mutating func parse(_ line: String) throws {
    guard var line = line.drop(while: \.isWhitespace).nonEmpty else {
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
    } else {
      let assignment = line.firstIndex(of: "=")
      let jump = assignment.flatMap { line[$0...].firstIndex(of: ";") }
        ?? line.firstIndex(of: ";")
      let comp = assignment.map(line.index(after:)) ?? line.startIndex

      switch (assignment, jump) {
      case let (assignment?, jump?):
        guard let dest = line[..<assignment].nonEmpty.flatMap(C.Destination.init),
          let comp = line[comp..<jump].nonEmpty.flatMap(C.Computation.init),
          let jump = line[line.index(after: jump)...].nonEmpty.flatMap(C.Jump.init)
          else { throw ParserError.invalidInstruction(String(line)) }
        instructions.append(.c(dest: dest, comp: comp, jump: jump))

      case let (assignment?, nil):
        guard let dest = line[..<assignment].nonEmpty.flatMap(C.Destination.init),
          let comp = line[comp...].nonEmpty.flatMap(C.Computation.init)
          else { throw ParserError.invalidInstruction(String(line)) }
        instructions.append(.c(dest: dest, comp: comp))

      case let (nil, jump?):
        guard let comp = line[comp..<jump].nonEmpty.flatMap(C.Computation.init),
          let jump = line[line.index(after: jump)...].nonEmpty.flatMap(C.Jump.init)
          else { throw ParserError.invalidInstruction(String(line)) }
        instructions.append(.c(comp: comp, jump: jump))

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
  public enum A: Equatable {
    case literal(Int)
    case symbol(String)
  }

  public enum C {
    public enum Computation: String, Equatable {
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
      case m = "M"
      case minusM = "-M"
      case notM = "!M"
      case mPlusOne = "M+1", onePlusM = "1+M"
      case mMinusOne = "M-1"
      case dPlusM = "D+M", mPlusD = "M+D"
      case dMinusM = "D-M"
      case mMinusD = "M-D"
      case dAndM = "D&M", mAndD = "M&D"
      case dOrM = "D|M", mOrD = "M|D"
    }

    public enum Destination: String, Equatable {
      case m = "M"
      case d = "D"
      case a = "A"
      case md = "MD", dm = "DM"
      case ma = "MA", am = "AM"
      case da = "DA", ad = "AD"
      case amd = "AMD", adm = "ADM", mad = "MAD", mda = "MDA", dam = "DAM", dma = "DMA"
    }

    public enum Jump: String, Equatable {
      case jgt = "JGT"
      case jeq = "JEQ"
      case jge = "JGE"
      case jlt = "JLT"
      case jne = "JNE"
      case jle = "JLE"
      case jmp = "JMP"
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

    case let .c(dest, comp, jump):
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
