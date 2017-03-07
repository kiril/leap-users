import Vapor
import Fluent
import Auth
import HTTP

final class User: Model, Auth.User {
    var id: Node?
    var email: String
    var password: String

    init(email: String, password: String) {
        self.email = email
        self.password = password
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("_id")
        email = try node.extract("email")
        password = try node.extract("password")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
                          "_id": id,
                          "email": email,
                          "password": password
                        ]
        )
    }

    public static func prepare(_ database: Fluent.Database) throws {
    }

    public static func revert(_ database: Fluent.Database) throws {
    }

    static func authenticate(credentials: Credentials) throws -> Auth.User {
        let user: User?

        guard let apiKey = credentials as? APIKey else {
            throw Abort.custom(status: .badRequest, message: "Bad authentication.")
        }

        user = try User.query().filter("email", apiKey.id.lowercased()).filter("password", apiKey.secret).first()

        guard let u = user else {
            throw Abort.custom(status: .unauthorized, message: "No matching user.")
        }

        return u
    }

    static func register(credentials: Credentials) throws -> Auth.User {
        let user: User?

        guard let apiKey = credentials as? APIKey else {
            throw Abort.custom(status: .badRequest, message: "Bad authentication.")
        }

        user = User(email: apiKey.id.lowercased(), password: apiKey.secret)
        try user!.save()

        return user!
    }
}
