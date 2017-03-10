import PackageDescription

let package = Package(
  name: "LeapUserService",
  targets: [Target(name: "LeapUserService", dependencies: [.Target(name: "VaporMongoKitten")])],
  dependencies: [
    .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 5),
    .Package(url: "https://github.com/OpenKitten/MongoKitten.git", majorVersion: 3),
    //.Package(url: "https://github.com/vapor/fluent.git", majorVersion: 1),
    //      .Package(url: "https://github.com/SingleLeap/vapor-mongokitten-provider.git", majorVersion: 1),
  ],
  exclude: [
    "Config",
    "Database",
    "Localization",
    "Public",
    "Resources",
  ]
)
