import Foundation

struct Food {
    var name: String
}

struct Location {
    var name: String
}

struct User {
    var favoriteFoods: [Food]
    var location: Location
    var name: String
}

var user = User(
    favoriteFoods: [Food(name: "Tacos"), Food(name: "Nachos")],
    location: Location(name: "Brooklyn"),
    name: "Blob"
)

user
    |> (^\.name) { "Mr. " + $0 }
    <> (^\.name) { $0.uppercased() }
    <> (^\.location.name) { _ in "Berlin" }
    <> (^\.favoriteFoods <<< map <<< ^\.name) { $0 + " & Salad"}

//user
//    |> over(^\.name, { "Mr. " + $0 })
//    <> over(^\.name, { $0.uppercased() })
//    <> set(^\.location.name, "Berlin")
//    <> over(^\.favoriteFoods <<< map <<< ^\.name, { $0 + " & Salad"})

let guaranteeHeaders = (^\URLRequest.allHTTPHeaderFields) { $0 ?? [:] }

let postJson =
    guaranteeHeaders
        <> (^\.httpMethod) { _ in "POST" }
        <> (^\.allHTTPHeaderFields <<< map <<< ^\.["Content-Type"]) { _ in
            "application/json; charset=utf-8"
}

let gitHubAccept =
    guaranteeHeaders
        <> (^\.allHTTPHeaderFields <<< map <<< ^\.["Accept"]) { _ in
            "application/vnd.github.v3+json"
}

let attachAuthorization = { token in
    guaranteeHeaders
        <> (^\.allHTTPHeaderFields <<< map <<< ^\.["Authorization"]) { _ in
            "Token " + token
    }
}

URLRequest(url: URL(string: "https://www.pointfree.co/hello")!)
    |> attachAuthorization("deadbeef")
    <> gitHubAccept
    <> postJson
