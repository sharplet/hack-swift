import ArgumentParser
import Hack
import Foundation
import SwiftIO

struct HSM: ParsableCommand {
  @Argument(help: .init(valueName: "File.asm"))
  var paths: [Path]

  @Flag(name: .shortAndLong, help: "Output binary files with a .bhack extension.")
  var binary: Bool

  func validate() throws {
    if paths.isEmpty {
      throw ValidationError("At least one path must be specified.")
    }

    for path in paths {
      guard path.extension == "asm" else {
        throw ValidationError("Hack assembly files must use the extension '.asm'.")
      }
    }
  }

  func run() throws {
    for path in paths {
      var destination = path
      destination.extension = binary ? "bhack" : "hack"

      try FileHandle.open(path) { file in
        file.writeErrorHandler = handleWriteError

        var parser = Parser()
        var symbols = SymbolTable()

        while let line = try file.readLine(strippingNewline: true) {
          try parser.parse(line, symbols: &symbols)
        }

        let program = Program(from: parser.instructions, symbols: &symbols)

        try FileHandle.open(destination, mode: .truncate, binary: binary) { destination in
          destination.writeErrorHandler = handleWriteError

          for instruction in program.instructions {
            if binary {
              try withUnsafeBytes(of: instruction.value.bigEndian, destination.write)
            } else {
              print(instruction.stringValue, to: &destination)
            }
          }
        }
      }
    }
  }

  func handleWriteError(_ error: POSIXError) {
    errorPrint("warning: Write failed:", error)
  }
}

HSM.main()
