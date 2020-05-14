import Foundation

extension Substring {
  mutating func eat<S: StringProtocol>(_ string: S) -> Bool {
    guard let range = range(of: string, options: .anchored) else {
      return false
    }
    removeSubrange(range)
    return true
  }
}
