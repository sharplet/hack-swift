import ArgumentParser
import SwiftIO

extension Path: ExpressibleByArgument {
  public init?(argument: String) {
    self.init(rawValue: argument)
  }
}
