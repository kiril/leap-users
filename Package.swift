import PackageDescription

let package = Package(
    name: "LeapUserService",
    dependencies: [
      .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 5),
      .Package(url: "https://github.com/OpenKitten/MongoKitten.git", majorVersion: 3)
    ],
    exclude: [
        "Config",
        "Database",
        "Localization",
        "Public",
        "Resources",
    ]
)

