import ArgumentParser
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
      try FileHandle.open(path, mode: .read) { file in
        while let line = try file.readLine(strippingNewline: true) {
          print(line)
        }
      }
    }
  }
}

HSM.main()
