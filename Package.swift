// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "sonoma_regex_bug_repro",
    targets: [
        .testTarget(
          name: "sonoma_regex_bug_repro"
        )
    ]
)
