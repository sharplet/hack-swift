import Foundation
import SwiftIO

public struct FileHandle {
  public static func open(
    _ path: Path,
    mode: Mode = .read,
    binary: Bool = false
  ) throws -> FileHandle {
    var mode = mode.rawValue
    if binary {
      mode += "b"
    }
    guard let handle = fopen(path.rawValue, mode) else {
      throw POSIXError.errno
    }
    return FileHandle(handle: handle)
  }

  public static func open<Result>(
    _ path: Path,
    mode: Mode = .read,
    binary: Bool = false,
    fileHandler: (inout FileHandle) throws -> Result
  ) throws -> Result {
    var file = try open(path, mode: mode, binary: binary)
    do {
      let result = try fileHandler(&file)
      try file.closeIfNeeded()
      return result
    } catch {
      try file.closeIfNeeded()
      throw error
    }
  }

  private let handle: UnsafeMutablePointer<FILE>
  private var isKnownClosed = false
  private var isKnownInvalid = false

  public var writeErrorHandler: ((POSIXError) -> Void)?

  public mutating func close() throws {
    precondition(!isKnownClosed)

    defer { isKnownInvalid = true }

    if fclose(handle) == 0 {
      isKnownClosed = true
    } else {
      throw POSIXError.errno
    }
  }

  private mutating func closeIfNeeded() throws {
    guard !isKnownClosed else { return }
    try close()
  }

  public func readLine(strippingNewline: Bool = false) throws -> String? {
    precondition(!isKnownInvalid, "Attempted to read an invalid file stream.")

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
        let index = buffer.index(before: end)
        switch Unicode.Scalar(buffer[index]) {
        case "\r", "\n":
          end = index
        default:
          break strip
        }
      }
    }

    return String(decoding: buffer[..<end], as: UTF8.self)
  }

  public func write<Bytes: Sequence>(_ bytes: Bytes) throws where Bytes.Element == UInt8 {
    var count = 0

    var countWritten = bytes.withContiguousStorageIfAvailable { buffer -> Int in
      count = buffer.count
      precondition(count > 0)
      return fwrite(buffer.baseAddress, 1, count, handle)
    }

    if countWritten == nil {
      let array = Array(bytes)
      count = array.count
      precondition(count > 0)
      countWritten = fwrite(array, 1, count, handle)
    }

    if countWritten != count {
      throw POSIXError.errno
    }
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
    precondition(!isKnownInvalid, "Attempted to write to an invalid file stream.")
    if fputs(string, handle) == EOF, let errorHandler = writeErrorHandler {
      errorHandler(.errno)
    }
  }
}
