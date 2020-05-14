public enum Instruction: Equatable {
  case a(Int)
  case c(dest: C.Destination? = nil, comp: C.Computation, jump: C.Jump? = nil)

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
}

extension Instruction: CustomStringConvertible {
  public var description: String {
    switch self {
    case let .a(value):
      return "@\(value)"
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
