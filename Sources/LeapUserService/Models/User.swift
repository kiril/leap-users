import Vapor
import Fluent
import Auth
import HTTP
import Foundation
import CryptoSwift

final class User: Model, Auth.User {
    var id: Node?
    var email: String
    var password: String
    var salt: String

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
        self.email = try node.extract("email")
        self.id = try! node.extract("id")

        let salt: String? = try! node.extract("salt")

        if let salt = salt {
            self.password = try node.extract("password")
            self.salt = salt
        } else {
            self.salt = User.createSalt()
            self.password = User.hashPassword(password: try node.extract("password"), salt: self.salt)
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
        return self.password == User.hashPassword(password: password, salt: self.salt)
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
                          "id": id,
                          "email": email,
                          "password": password,
                          "salt": salt
                        ]
        )
    }

    public static func prepare(_ database: Fluent.Database) throws {
        //database.create("users")
    }

    public static func revert(_ database: Fluent.Database) throws {
    }

    static func authenticate(credentials: Credentials) throws -> Auth.User {
        guard let apiKey = credentials as? APIKey else {
            throw Abort.custom(status: .badRequest, message: "Bad authentication.")
        }

        let email = apiKey.id.lowercased()
        let password = apiKey.secret

        guard let user = try User.query().filter("email", email).first() else {
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
