import Foundation
import Darwin

import Vapor
import VaporMongo
import HTTP
import Auth

let drop = Droplet()
try drop.addProvider(VaporMongo.Provider.self)
drop.middleware.append(AuthMiddleware(user: LeapUserService.User.self))

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
    guard let user = try User.query().filter("email", credentials.id).first() else {
        print("No such user")
        throw Abort.custom(status: Status.unauthorized, message: "No such user.")
    }
    return "Hi there friend!"
}

drop.run()
