import ArgumentParser
import IO

extension Path: ExpressibleByArgument {
  public init?(argument: String) {
    self.init(rawValue: argument)
  }
}
