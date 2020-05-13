import Foundation

func createTemporaryDirectory(withTemplate template: String) throws -> URL {
  try (NSTemporaryDirectory() as NSString).appendingPathComponent(template).withCString { template in
    guard let template = strdup(template) else {
      throw POSIXError.errno
    }
    defer { free(template) }

    if let path = mkdtemp(template) {
      return URL(fileURLWithPath: String(cString: path), isDirectory: true)
    } else {
      throw POSIXError.errno
    }
  }
}
