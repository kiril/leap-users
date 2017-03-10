import Vapor
import FluentMongo

public final class Provider: Vapor.Provider {
    public let driver: FluentMongo.MongoDriver
    public let database: Database

    public enum Error: Swift.Error {
        case config(String)
        case unsupported(String)
    }

    public init(connectionString: String) throws {
        let driver = try FluentMongo.MongoDriver(connectionString: connectionString)
        self.driver = driver
        self.database = Fluent.Database(driver)
    }

    public convenience init(config: Config) throws {
        guard let connectionString = config["mongo"]?["connection_string"]?.string else {
            throw Error.config("Mongo.json missing 'connection_string'.")
        }
        try self.init(connectionString: connectionString)
    }

    public func boot(_ drop: Droplet) {
        drop.database = database
    }

    public func afterInit(_ drop: Droplet) {

    }

    public func beforeRun(_ drop: Droplet) {

    }

}
