extension RawRepresentable where RawValue == String {
  public init?(substring: Substring) {
    self.init(rawValue: String(substring))
  }
}
