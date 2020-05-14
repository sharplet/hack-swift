extension Collection {
  var nonEmpty: Self? {
    isEmpty ? nil : self
  }
}
