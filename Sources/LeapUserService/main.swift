import Foundation

import Vapor
import VaporMongo
import HTTP
import Auth

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

// it's nice to see logs on Heroku and stuff
setlinebuf(stdout)


let drop = Droplet()
// Mongo
try drop.addProvider(VaporMongo.Provider.self)
// Auth
drop.middleware.append(AuthMiddleware(user: LeapUserService.User.self))

// Views... these should go elsewhere...

drop.get("/") { request in
    return Response(redirect: "http://www.singleleap.com")
}

drop.get("hello") { request in
    return "Hello, Swifty World!"
}

drop.get("authenticate", "basic") { request in
    print("authenticate/basic called...")

    guard let credentials = request.auth.header?.basic else {
        print("No HTTP Auth Headers")
        throw Abort.badRequest
    }

    print("Retrieving the user:")
    guard let user = try User.query().filter("email", credentials.id).first() else {
        print("No such user. \(credentials.id)")
        throw Abort.custom(status: Status.unauthorized, message: "No such user.")
    }

    print("Found the user.")

    return "Hi there friend!"
}

drop.run()
