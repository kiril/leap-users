import Vapor

let drop = Droplet()

drop.get("/hello") { request in
    return "Hello, Swifty World!"
}

drop.get("/authenticate", "basic") { request in
    print(request.headers)
    guard let auth = request.headers["Authorization"] else {
        print("bad request, bad!")
        throw Abort.badRequest
    }
    print("got a good auth request")
    return "Hi there friend!"
}

drop.run()
