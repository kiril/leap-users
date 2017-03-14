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

drop.group("test") { test in
    test.get("create") { request in
        var user = User(email: "kiril.savino@gmail.com",
                        password: "f00tfall")
        try user.save()
        return "Created"
    }

    test.get("verify") { request in
         var user = try User.query().filter("email", "kiril.savino@gmail.com").first()
         guard var u = user else {
             throw Abort.serverError
         }
         u.verified = true
         try u.save()
         return "Verified"
    }

    test.get("get") { request in
        if let user = try User.find("58c71745234dfb7b21bb4cfa") {
            print(user.email)
        }
        return "Shit, wow"
    }
}


drop.group("api") { api in
    typealias LeapUser = LeapUserService.User

    api.group("v1") { v1 in

        v1.get("authenticate", "basic") { request in
            guard let credentials = request.auth.header?.basic else {
                throw Abort.badRequest
            }

            return try LeapUser.auth(credentials: credentials).toJSON()
        }

        v1.put("verify") { request in
            guard let email = request.data["email"]?.string else {
                throw Abort.custom(status: .unauthorized, message: "Authorization failed.")
            }

            guard var user = try User.query().filter("email", email.lowercased()).first() else {
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
