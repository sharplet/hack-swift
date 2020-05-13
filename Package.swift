// swift-tools-version:5.2

import PackageDescription

extension Target.Dependency {
  static var argumentParser: Target.Dependency {
    .product(name: "ArgumentParser", package: "swift-argument-parser")
  }
}

let package = Package(
  name: "hsm",
  platforms: [
    .macOS(.v10_15),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-argument-parser.git", from: "0.0.1"),
  ],
  targets: [
    .target(name: "hsm", dependencies: [.argumentParser]),
    .testTarget(name: "hsmTests", dependencies: ["hsm"]),
  ]
)
