import class Foundation.Bundle
import XCTest

// swiftlint:disable:next type_name
final class hsmTests: XCTestCase {
  func testExample() throws {
    let pipe = Pipe()
    let process = Process()
    process.executableURL = productsDirectory.appendingPathComponent("hsm")
    process.standardOutput = pipe
    try process.run()
    process.waitUntilExit()

    let data = try pipe.fileHandleForReading.readToEnd() ?? Data()
    let output = String(data: data, encoding: .utf8)

    XCTAssertEqual(output, "Hello, world!\n")
  }

  var productsDirectory: URL {
    for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
      return bundle.bundleURL.deletingLastPathComponent()
    }
    fatalError("couldn't find the products directory")
  }
}
