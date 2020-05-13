import ArgumentParser
import Foundation
import SwiftIO

struct HSM: ParsableCommand {
  @Argument(help: .init(valueName: "File.asm"))
  var paths: [Path]

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
      destination.extension = "hack"

      try FileHandle.open(path) { file in
        file.writeErrorHandler = handleWriteError

        try FileHandle.open(destination, mode: .truncate) { destination in
          destination.writeErrorHandler = handleWriteError

          while let line = try file.readLine(strippingNewline: true) {
            print(line, to: &destination)
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
