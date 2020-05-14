public struct Program {
  public private(set) var instructions: [Hack.Instruction]

  public init<Instructions: Collection>(
    from input: Instructions,
    symbols: inout SymbolTable
  ) where Instructions.Element == Parser.Instruction {
    self.instructions = []
    self.instructions.reserveCapacity(input.count)

    for instruction in input {
      switch instruction {
      case let .resolved(instruction):
        self.instructions.append(instruction)
      case let .symbolic(symbol):
        if let value = symbols[symbol] {
          self.instructions.append(.a(value))
        } else {
          let value = symbols.allocate(symbol)
          self.instructions.append(.a(value))
        }
      }
    }
  }
}
