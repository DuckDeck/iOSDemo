// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MediaPackage",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MediaPackage",
            targets: ["MediaPackage"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/SnapKit/SnapKit", from: "5.0.1"),
        .package(url: "https://github.com/longitachi/ZLPhotoBrowser", from: "4.1.2"),
        .package(url: "https://github.com/kaishin/Gifu", from: "3.0.0"),
        .package(path: "../CommonLibrary")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MediaPackage",
            dependencies: ["SnapKit","CommonLibrary","ZLPhotoBrowser","Gifu"]),
        .testTarget(
            name: "MediaPackageTests",
            dependencies: ["MediaPackage"]),
    ]
)
