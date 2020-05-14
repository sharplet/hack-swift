extension Collection {
  var nonEmpty: Self? {
    isEmpty ? nil : self
  }
}

extension BidirectionalCollection {
  func suffix(while predicate: (Element) throws -> Bool) rethrows -> SubSequence {
    var suffix = endIndex
    while suffix > startIndex {
      let next = index(before: suffix)
      if try predicate(self[next]) {
        suffix = next
        continue
      } else {
        break
      }
    }
    return self[suffix ..< endIndex]
  }
}
