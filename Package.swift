import PackageDescription

let package = Package(
  name: "LeapUserService",
  targets: [Target(name: "LeapUserService",
                   dependencies: [.Target(name: "VaPurr")])],
  dependencies: [
    .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 5),
    .Package(url: "https://github.com/SingleLeap/mongo-driver.git", "1.0.10-mk3-alpha"),
    .Package(url: "https://github.com/vapor/crypto.git", majorVersion: 1),
  ],
  exclude: [
    "Config",
    "Database",
    "Localization",
    "Public",
    "Resources",
  ]
)
