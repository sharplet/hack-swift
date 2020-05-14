public enum ParserError: Error {
  case aInstructionMissingIdentifier
  case invalidInstruction(String)
}
