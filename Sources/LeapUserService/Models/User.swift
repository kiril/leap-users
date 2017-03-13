import Vapor
import Fluent
import Auth
import HTTP
import Foundation
import CryptoSwift

final class User: Model, Auth.User, Audited {
    var id: Node?
    var email: String
    var password: String
    var salt: String
    var verified: Bool?
    var created: NSDate?
    var updated: NSDate?


    var exists: Bool = false

    init(email: String, password: String, salt: String) {
        self.email = email
        self.password = password
        self.salt = salt
    }

    private init(email: String, password: String) {
        self.email = email
        self.salt = User.createSalt()
        self.password = User.hashPassword(password: password, salt: salt)
    }

    init(node: Node, in context: Context) throws {
        self.email = try node.extract("email").string.lowercased()
        self.id = try! node.extract("_id")

        let salt: String? = try! node.extract("salt")

        if let salt = salt {
            self.password = try node.extract("password")
            self.salt = salt
        } else {
            self.salt = User.createSalt()
            self.password = User.hashPassword(password: try node.extract("password"), salt: self.salt)
        }

        print("node.extract('verified') =")
        debugPrint(node["verified"])
        print(node["verified"])

        if let verified: Bool = try node.extract("verified") {
            self.verified = verified // Bool(verified as NSNumber)
        }
    }

    private static func createSalt() -> String {
        return UUID().uuidString
    }

    private static func hashPassword(password: String, salt: String) -> String {
        return try! Data("\(salt)\(password)".makeBytes()).sha256().hexString.lowercased()
    }

    func updatePassword(to password: String) {
        self.salt = User.createSalt()
        self.password = User.hashPassword(password: password, salt: self.salt)
    }

    func passwordMatches(password: String) -> Bool {
        let hashed = User.hashPassword(password: password, salt: self.salt)
        return self.password == hashed
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
                          "_id": id,
                          "email": email,
                          "password": password,
                          "salt": salt
                        ]
        )
    }

    func toJSON() throws -> JSON {
        return try JSON(node: ["user_id": id, "email": email])
    }

    public static func prepare(_ database: Fluent.Database) throws {
        //database.create("users")
    }

    public static func revert(_ database: Fluent.Database) throws {
    }

    static func auth(credentials: Credentials) throws -> User {
        return try User.authenticate(credentials: credentials) as! User
    }

    static func authenticate(credentials: Credentials) throws -> Auth.User {
        guard let apiKey = credentials as? APIKey else {
            throw Abort.custom(status: .badRequest, message: "Bad authentication.")
        }

        let email = apiKey.id.lowercased()
        let password = apiKey.secret

        guard let user = try User.query().filter("email", email.lowercased()).first() else {
            throw Abort.custom(status: .unauthorized, message: "Authorization failure.")
        }

        if !user.passwordMatches(password: password) {
            throw Abort.custom(status: .unauthorized, message: "Authorization failure.")
        }

        return user
    }

    static func register(credentials: Credentials) throws -> Auth.User {
        guard let apiKey = credentials as? APIKey else {
            throw Abort.custom(status: .badRequest, message: "Bad authentication.")
        }

        var user = User(email: apiKey.id.lowercased(), password: apiKey.secret)
        try user.save()
        return user
    }
}
