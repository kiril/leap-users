import PackageDescription

let package = Package(
    name: "LeapUserService",
    dependencies: [
      .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 5),
      .Package(url: "https://github.com/vapor/mongo-provider.git", majorVersion: 1, minor: 1),
      .Package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", majorVersion: 1),
      .Package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver-Vapor.git", majorVersion: 1),
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)

