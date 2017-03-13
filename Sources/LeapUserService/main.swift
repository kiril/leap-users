import Foundation

import Vapor
import VaPurr
import HTTP
import Auth

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif


let drop = Droplet()
// Mongo
try drop.addProvider(VaPurr.Provider.self)
// Auth
drop.middleware.append(AuthMiddleware(user: LeapUserService.User.self))
// Models
drop.preparations.append(LeapUserService.User.self)

// it's nice to see logs on Heroku and stuff
setlinebuf(stdout)

// Views... these should go elsewhere...


drop.get("/") { request in
    return Response(redirect: "http://www.singleleap.com")
}

drop.get("hello") { request in
    return "Hello, Swifty World!"
}


drop.group("api") { api in
    typealias LeapUser = LeapUserService.User

    api.group("v1") { v1 in

        v1.get("authenticate", "basic") { request in
            drop.log.info("authenticate/basic called...")

            guard let credentials = request.auth.header?.basic else {
                drop.log.warning("No HTTP Auth Headers")
                throw Abort.badRequest
            }

            drop.log.debug("Logging in [log]")
            print("Logging in [print]")

            return try LeapUser.auth(credentials: credentials).toJSON()
        }

        v1.put("verify") { request in
            print("Verify request data:")
            print(request.data)
            guard let email = request.data["email"]?.string else {
                print("missing email string in request data")
                throw Abort.custom(status: .unauthorized, message: "Authorization failed.")
            }

            print("A User:")
            print(try User.query().first())

            print("Querying by email... \(email)")

            guard var user = try User.query().filter("email", email.lowercased()).first() else {
                print("no such user as \(email)")
                throw Abort.custom(status: .unauthorized, message: "Authorization failed.")
            }

            user.verified = true
            try user.save()
            return "OK"
        }

        v1.resource("users", UserController())
    }
}

drop.run()
