// swift-tools-version:4.0

import PackageDescription

let package = Package(
  name: "JSONFragmentDecoding",
  products: [
    .library(
      name: "JSONFragmentDecoding",
      targets: ["JSONFragmentDecoding"]
    ),
  ],
  dependencies: [
    
  ],
  targets: [
    .target(
      name: "JSONFragmentDecoding",
      dependencies: []
    ),
    .testTarget(
      name: "JSONFragmentDecodingTests",
      dependencies: ["JSONFragmentDecoding"]
    ),
  ]
)
