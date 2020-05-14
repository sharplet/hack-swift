import Foundation

extension Substring {
  mutating func eat<S: StringProtocol>(_ string: S) -> Bool {
    guard let range = range(of: string, options: .anchored) else {
      return false
    }
    removeSubrange(range)
    return true
  }

  mutating func eat<R: RawRepresentable & CaseIterable>(
    _: R.Type
  ) -> R? where R.RawValue == String {
    let cases = R.allCases.sorted(by: { $0.rawValue.count > $1.rawValue.count })
    for `case` in cases {
      if eat(`case`.rawValue) {
        return `case`
      }
    }
    return nil
  }
}
