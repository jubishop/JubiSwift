// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "JubiSwift",
  platforms: [.iOS(.v16), .macOS(.v13)],
  products: [
    .library(
      name: "JubiSwift",
      targets: ["JubiSwift"]
    )
  ],
  targets: [
    .target(
      name: "JubiSwift"
    ),
    .testTarget(
      name: "JubiSwiftTests",
      dependencies: ["JubiSwift"]
    ),
  ]
)
