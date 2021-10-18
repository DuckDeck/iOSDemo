// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProjectPackage",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "ProjectPackage",
            targets: ["ProjectPackage"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/SnapKit/SnapKit", from: "5.0.1"),
        .package(path: "../CommonLibrary"),
        .package(url: "https://github.com/kaishin/Gifu", from: "3.0.0"),
        .package(url: "https://github.com/SwiftyJSON/SwiftyJSON", from: "5.0.0")
        
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "ProjectPackage",
            dependencies: ["SnapKit","CommonLibrary","Gifu","SwiftyJSON"]),
        .testTarget(
            name: "ProjectPackageTests",
            dependencies: ["ProjectPackage"]),
    ]
)
