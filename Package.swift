// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SerialPort+Combine",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SerialPort+Combine",
            targets: ["SerialPort+Combine"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/armadsen/ORSSerialPort.git", from: "2.1.0"),
        .package(url: "https://github.com/realm/SwiftLint.git", from: "0.54.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SerialPort+Combine",
            dependencies: [
                .product(name: "ORSSerial", package: "orsserialport"),
            ],
            plugins: [.plugin(name: "SwiftLintPlugin", package: "SwiftLint")]
        ),
        .testTarget(
            name: "SerialPort+CombineTests",
            dependencies: ["SerialPort+Combine"]),
    ]
)
