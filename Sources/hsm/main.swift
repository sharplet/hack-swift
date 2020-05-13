import ArgumentParser

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
    print("Hello, world!")
  }
}

HSM.main()
