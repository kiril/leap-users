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

    init(email: String, password: String) {
        self.email = email
        self.salt = User.createSalt()
        self.password = User.hashPassword(password: password, salt: salt)
    }

    init(node: Node, in context: Context) throws {
        self.email = try node.extract("email")
        self.email = self.email.lowercased()
        self.id = try! node.extract("_id")

        let salt: String? = try! node.extract("salt")

        if let salt = salt {
            self.password = try node.extract("password")
            self.salt = salt
        } else {
            self.salt = User.createSalt()
            self.password = User.hashPassword(password: try node.extract("password"), salt: self.salt)
        }

        if let verified: Bool = try node.extract("verified") {
            self.verified = verified
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
        var data: [String: Node?] = ["_id": id,
                                     "email": Node(email),
                                     "password": Node(password),
                                     "salt": Node(salt)]
        if let verified = self.verified {
            data["verified"] = Node(verified)
        }
        return try Node(node: data)
    }

    func toJSON() throws -> JSON {
        return try JSON(node: ["user_id": id, "email": email])
    }

    public static func find(_ id: NodeRepresentable) throws -> User? {
        if let stringId = id as? String {
            if stringId.characters.count == 24 {
                return try User.query().filter("_id", stringId).first()
            }
            return try User.query().filter("email", stringId).first()
        }

        throw SchemaError.badData(field: "id")
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
