// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MonetaryExchange",
    products: [
        .library(
            name: "MonetaryExchange",
            type: .static,
            targets: ["MonetaryExchange"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SoftwareEngineerChris/MonetaryAmount.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "MonetaryExchange",
            dependencies: ["MonetaryAmount"]),
        .target(
            name: "MonetaryExchangeSample",
            dependencies: ["MonetaryExchange"]
        ),
        .testTarget(
            name: "MonetaryExchangeTests",
            dependencies: ["MonetaryExchange", "MonetaryExchangeSample"]),
    ]
)
