public enum ParserError: Error {
  case aInstructionMissingIdentifier
  case duplicateLabel(String)
  case invalidInstruction(String)
  case unclosedLabel(String)
}
