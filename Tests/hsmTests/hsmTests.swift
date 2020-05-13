import class Foundation.Bundle
import XCTest

// swiftlint:disable:next type_name
final class hsmTests: XCTestCase {
  var temporaryDirectory: URL!

  override func setUpWithError() throws {
    try super.setUpWithError()
    temporaryDirectory = try createTemporaryDirectory(withTemplate: "hsmTests-XXXXXX")
  }

  override func tearDownWithError() throws {
    try FileManager.default.removeItem(at: temporaryDirectory)
    try super.tearDownWithError()
  }

  func testExample() throws {
    let foo = temporaryDirectory.appendingPathComponent("foo.asm", isDirectory: false)
    try Data("foo\n".utf8).write(to: foo)
    let bar = temporaryDirectory.appendingPathComponent("bar.asm", isDirectory: false)
    try Data("bar\n".utf8).write(to: bar)

    let pipe = Pipe()
    let process = Process()
    process.executableURL = productsDirectory.appendingPathComponent("hsm")
    process.arguments = [foo.path, bar.path]
    process.standardError = pipe
    process.standardOutput = pipe
    try process.run()
    process.waitUntilExit()

    let data = try pipe.fileHandleForReading.readToEnd() ?? Data()
    let output = String(data: data, encoding: .utf8)

    XCTAssertEqual(output, "foo\nbar\n")
  }

  var productsDirectory: URL {
    for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
      return bundle.bundleURL.deletingLastPathComponent()
    }
    fatalError("couldn't find the products directory")
  }
}
