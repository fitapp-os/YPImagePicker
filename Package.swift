// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "YPImagePicker",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "YPImagePicker",
            targets: ["YPImagePicker"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/MarkusFriedlBP/Stevia.git", from: "5.2.0"),
         .package(url: "https://github.com/HHK1/PryntTrimmerView.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "YPImagePicker",
            dependencies: [],
            path: "Source"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
