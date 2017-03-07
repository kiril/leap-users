import Vapor
import HTTP
import MongoKitten
import Foundation

let env = ProcessInfo.processInfo.environment
let mongoURL = env["MONGOHQ_URL"] ?? env["MONGO_URL"] ?? "mongodb://localhost:27017"
print(mongoURL)
let mongo = try Server(mongoURL: mongoURL)
let db = mongo["users"]

let drop = Droplet()

drop.get("/") { request in
    return Response(redirect: "http://www.singleleap.com")
}

drop.get("hello") { request in
    return "Hello, Swifty World!"
}

drop.get("authenticate", "basic") { request in
    print("Auth request headers:")
    print(request.headers)
    fflush(__stdoutp)

    guard let credentials = request.auth.header?.basic else {
        print("bad request, bad!")
        throw Abort.badRequest
    }

    print("got a good auth request! I should do something with that...")
    guard let user = db["user"].findOne(["email": credentials.id]) else {
        print("No such user")
        throw Abort.unauthorized
    }
    return "Hi there friend!"
}

drop.run()
