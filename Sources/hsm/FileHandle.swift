import Foundation
import SwiftIO

public struct FileHandle {
  public static func open(_ path: Path, mode: Mode = .read) throws -> FileHandle {
    guard let handle = fopen(path.rawValue, mode.rawValue) else {
      throw POSIXError.errno
    }
    return FileHandle(handle: handle)
  }

  public static func open<Result>(_ path: Path, mode: Mode = .read, fileHandler: (inout FileHandle) throws -> Result) throws -> Result {
    var file = try open(path, mode: mode)
    do {
      let result = try fileHandler(&file)
      try file.close()
      return result
    } catch {
      if file.isOpen {
        try file.close()
      }
      throw error
    }
  }

  private var handle: UnsafeMutablePointer<FILE>!
  private var isInvalid: Bool = false

  public var isOpen: Bool {
    handle != nil
  }

  public var writeErrorHandler: ((POSIXError) -> Void)?

  public mutating func close() throws {
    precondition(isOpen)

    defer { isInvalid = true }

    if fclose(handle) == 0 {
      handle = nil
    } else {
      throw POSIXError.errno
    }
  }

  public func readLine(strippingNewline: Bool = false) throws -> String? {
    precondition(!isInvalid, "Attempted to read an invalid file stream.")

    var count = 0
    guard let pointer = fgetln(handle, &count) else {
      if ferror(handle) != 0 {
        throw POSIXError.errno
      } else {
        return nil
      }
    }

    let utf8 = UnsafeRawPointer(pointer).assumingMemoryBound(to: UInt8.self)
    let buffer = UnsafeBufferPointer(start: utf8, count: count)
    var end = buffer.endIndex

    if strippingNewline {
      strip: while end > buffer.startIndex {
        let i = buffer.index(before: end)
        switch Unicode.Scalar(buffer[i]) {
        case "\r", "\n":
          end = i
        default:
          break strip
        }
      }
    }

    return String(decoding: buffer[..<end], as: UTF8.self)
  }
}

extension FileHandle {
  public enum Mode: String {
    case read = "r"
    case readWrite = "r+"
    case truncate = "w"
    case readTruncate = "w+"
    case new = "wx"
    case readWriteNew = "w+x"
    case append = "a"
    case readAppend = "a+"
  }
}

extension FileHandle: TextOutputStream {
  public func write(_ string: String) {
    precondition(!isInvalid, "Attempted to write to an invalid file stream.")
    if fputs(string, handle) == EOF, let errorHandler = writeErrorHandler {
      errorHandler(.errno)
    }
  }
}
