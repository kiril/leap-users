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

drop.get("authenticate", "basic") { request in
    drop.log.info("authenticate/basic called...")

    guard let credentials = request.auth.header?.basic else {
        drop.log.warning("No HTTP Auth Headers")
        throw Abort.badRequest
    }

    drop.log.debug("Logging in [log]")
    print("Logging in [print]")

    let user = try LeapUserService.User.authenticate(credentials: credentials) as! LeapUserService.User

    return try user.toJSON()
}

drop.resource("users", UserController())


drop.run()
