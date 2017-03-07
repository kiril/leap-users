import Foundation

import Vapor
import VaporMongo
import HTTP
import Auth
import SwiftyBeaverVapor
import SwiftyBeaver

let drop = Droplet()

// Mongo
try drop.addProvider(VaporMongo.Provider.self)
// Auth
drop.middleware.append(AuthMiddleware(user: LeapUserService.User.self))
// SwiftyBeaver
let console = ConsoleDestination()
//console.format = "$DHH:mm:ss$d $L $M"
drop.addProvider(SwiftyBeaverProvider(destinations: [console]))

let log = drop.log.self

log.verbose("not so important")  // prio 1, VERBOSE in silver
log.debug("something to debug")  // prio 2, DEBUG in green
log.info("a nice information")   // prio 3, INFO in blue
log.warning("oh no, that won’t be good")  // prio 4, WARNING in yellow
log.error("ouch, an error did occur!")  // prio 5, ERROR in red


drop.get("/") { request in
    return Response(redirect: "http://www.singleleap.com")
}

drop.get("hello") { request in
    return "Hello, Swifty World!"
}

drop.get("authenticate", "basic") { request in
    guard let credentials = request.auth.header?.basic else {
        log.error("No HTTP Auth Headers")
        throw Abort.badRequest
    }

    log.info("Got an auth request that looks good...")
    print("got a good auth request! I should do something with that...")
    guard let user = try User.query().filter("email", credentials.id).first() else {
        log.error("No such user exists!")
        throw Abort.custom(status: Status.unauthorized, message: "No such user.")
    }

    print("Fuck yeah, got through auth!")
    return "Hi there friend!"
}

drop.run()
