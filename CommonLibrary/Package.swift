// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CommonLibrary",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "CommonLibrary",
            targets: ["CommonLibrary"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/SnapKit/SnapKit", from: "5.0.1"),
        .package(url: "https://github.com/DuckDeck/GrandTime", from: "2.0.0"),
        .package(url: "https://github.com/onevcat/Kingfisher", from: "6.0.0"),
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.4.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "CommonLibrary",
            dependencies: ["SnapKit","GrandTime","Kingfisher","Alamofire"]),
        .testTarget(
            name: "CommonLibraryTests",
            dependencies: ["CommonLibrary"]),
    ]
)
