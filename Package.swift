// swift-tools-version:3.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProtobufGeneratorUtils",
    dependencies: [
        .Package(url: "https://github.com/alexeyxo/protobuf-swift.git", majorVersion: 3),
    ]
)

