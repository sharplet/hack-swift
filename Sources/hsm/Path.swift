import ArgumentParser
import Foundation

public struct Path: RawRepresentable {
  public var rawValue: String

  public init(rawValue: String) {
    if rawValue.isEmpty {
      self.rawValue = "."
    } else {
      self.rawValue = rawValue
    }
  }

  public var components: [Substring] {
    var components = rawValue.split(separator: "/", omittingEmptySubsequences: true)
    if let range = rawValue.range(of: "/", options: .anchored) {
      components.insert(rawValue[range], at: 0)
    }
    return components
  }

  public var `extension`: Substring {
    guard let basename = components.last else { return "" }
    var separator = basename.lastIndex(of: ".") ?? basename.endIndex
    _ = basename.formIndex(&separator, offsetBy: 1, limitedBy: basename.endIndex)
    return basename[separator...]
  }
}

extension Path: ExpressibleByArgument {
  public init?(argument: String) {
    self.init(rawValue: argument)
  }
}

extension Path: ExpressibleByStringLiteral {
  public init(stringLiteral value: StringLiteralType) {
    self.init(rawValue: value)
  }
}
