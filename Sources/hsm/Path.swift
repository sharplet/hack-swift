import ArgumentParser
import Foundation

struct Path: RawRepresentable {
  var rawValue: String

  var components: [Substring] {
    var components = rawValue.split(separator: "/", omittingEmptySubsequences: true)
    if let range = rawValue.range(of: "/", options: .anchored) {
      components.insert(rawValue[range], at: 0)
    }
    return components
  }

  var `extension`: Substring {
    guard let basename = components.last else { return "" }
    var separator = basename.lastIndex(of: ".") ?? basename.endIndex
    _ = basename.formIndex(&separator, offsetBy: 1, limitedBy: basename.endIndex)
    return basename[separator...]
  }
}

extension Path: ExpressibleByArgument {
  init?(argument: String) {
    if argument.isEmpty {
      self.init(rawValue: ".")
    } else {
      self.init(rawValue: argument)
    }
  }
}
