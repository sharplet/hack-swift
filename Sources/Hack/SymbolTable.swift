public struct SymbolTable {
  private var counter: Int
  private var symbols: [String: Int]

  public init() {
    counter = 16
    symbols = [
      "R0": 0,
      "R1": 1,
      "R2": 2,
      "R3": 3,
      "R4": 4,
      "R5": 5,
      "R6": 6,
      "R7": 7,
      "R8": 8,
      "R9": 9,
      "R10": 10,
      "R11": 11,
      "R12": 12,
      "R13": 13,
      "R14": 14,
      "R15": 15,
      "SP": 0,
      "LCL": 1,
      "ARG": 2,
      "THIS": 3,
      "THAT": 4,
      "SCREEN": 0x4000,
      "KBD": 0x6000,
    ]
  }

  public subscript(symbol: String) -> Int? {
    symbols[symbol]
  }

  internal subscript(label symbol: String) -> Int? {
    get { symbols[symbol] }
    set { symbols[symbol] = newValue }
  }

  public mutating func allocate(_ symbol: String) -> Int {
    precondition(symbols[symbol] == nil)
    defer { counter += 1 }
    symbols[symbol] = counter
    return counter
  }
}
