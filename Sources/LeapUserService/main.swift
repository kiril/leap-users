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
    drop.log.info("authenticate/basic called...")

    guard let credentials = request.auth.header?.basic else {
        drop.log.warning("No HTTP Auth Headers")
        throw Abort.badRequest
    }

    drop.log.debug("Logging in")
    do {
        try request.auth.login(credentials)
    } catch {
        drop.log.warning("Login failed with an error! \(error)")
    }
    drop.log.debug("Successfully logged in")

    return "Hi there friend!"
}

drop.run()
