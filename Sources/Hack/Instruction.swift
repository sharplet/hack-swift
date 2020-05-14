public enum Instruction: Equatable {
  case a(Int)
  case c(dest: C.Destination? = nil, comp: C.Computation, jump: C.Jump? = nil)

  public var stringValue: String {
    let value = self.value
    var i = UInt16(0x8000)
    var output = ""
    while i > 0 {
      if i & value > 0 {
        output += "1"
      } else {
        output += "0"
      }
      i >>= 1
    }
    return output
  }

  public var value: UInt16 {
    switch self {
    case let .a(value):
      return 0x7FFF & UInt16(bitPattern: numericCast(value))
    case let .c(dest, comp, jump):
      let jump = jump?.value ?? 0
      let dest = dest?.value ?? 0
      let comp = comp.value
      return 0xE000 | comp << 6 | dest << 3 | jump
    }
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

      public var value: UInt16 {
        switch self {
        case .zero:                 return 0b0101010
        case .one:                  return 0b0111111
        case .minusOne:             return 0b0111010
        case .d:                    return 0b0001100
        case .a:                    return 0b0110000; case .m:                    return 0b1110000
        case .notD:                 return 0b0001101
        case .notA:                 return 0b0110001; case .notM:                 return 0b1110001
        case .minusD:               return 0b0001111
        case .minusA:               return 0b0110011; case .minusM:               return 0b1110011
        case .dPlusOne, .onePlusD:  return 0b0011111
        case .aPlusOne, .onePlusA:  return 0b0110111; case .mPlusOne, .onePlusM:  return 0b1110111
        case .dMinusOne:            return 0b0001110
        case .aMinusOne:            return 0b0110010; case .mMinusOne:            return 0b1110010
        case .dPlusA, .aPlusD:      return 0b0000010; case .dPlusM, .mPlusD:      return 0b1000010
        case .dMinusA:              return 0b0010011; case .dMinusM:              return 0b1010011
        case .aMinusD:              return 0b0000111; case .mMinusD:              return 0b1000111
        case .dAndA, .aAndD:        return 0b0000000; case .dAndM, .mAndD:        return 0b1000000
        case .dOrA, .aOrD:          return 0b0010101; case .dOrM, .mOrD:          return 0b1010101
        }
      }
    }

    public enum Destination: String, Equatable {
      case m = "M"
      case d = "D"
      case md = "MD", dm = "DM"
      case a = "A"
      case am = "AM", ma = "MA"
      case ad = "AD", da = "DA"
      case amd = "AMD", adm = "ADM", mad = "MAD", mda = "MDA", dam = "DAM", dma = "DMA"

      public var value: UInt16 {
        switch self {
        case .m:        return 0b001
        case .d:        return 0b010
        case .md, .dm:  return 0b011
        case .a:        return 0b100
        case .am, .ma:  return 0b101
        case .ad, .da:  return 0b110
        default:        return 0b111
        }
      }
    }

    public enum Jump: String, Equatable {
      case jgt = "JGT"
      case jeq = "JEQ"
      case jge = "JGE"
      case jlt = "JLT"
      case jne = "JNE"
      case jle = "JLE"
      case jmp = "JMP"

      public var value: UInt16 {
        switch self {
        case .jgt: return 0b001
        case .jeq: return 0b010
        case .jge: return 0b011
        case .jlt: return 0b100
        case .jne: return 0b101
        case .jle: return 0b110
        case .jmp: return 0b111
        }
      }
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
