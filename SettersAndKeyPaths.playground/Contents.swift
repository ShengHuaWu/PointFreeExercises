import Foundation

precedencegroup ForwardApplication {
    associativity: left
}

infix operator |>: ForwardApplication
func |> <A, B>(_ a: A, _ f: @escaping (A) -> B) -> B {
    return f(a)
}

struct User {
    var name: String
    var age: Int
    var phone: String
}

extension User: CustomStringConvertible {
    var description: String {
        return "\(name)\n\(age)\n\(phone)"
    }
}

var user = User(name: "Bob", age: 44, phone: "+4912345678")
user = User(name: user.name, age: 45, phone: user.phone)

func prop<Root, Value>(_ keyPath: WritableKeyPath<Root, Value>) -> (@escaping (Value) -> Value) -> (Root) -> Root {
    return { update in
        return { root in
            var copy = root
            copy[keyPath: keyPath] = update(copy[keyPath: keyPath])
            return copy
        }
    }
}

user
    |> (prop(\.age)) { $0 + 1 }
    |> (prop(\.name)) { $0.uppercased() }
    |> (prop(\.phone)) { $0 + "9" }

\[String: String].["Content-Type"]
var headers: [String: String?] = [:]
headers
    |> (prop(\.["Content-Type"])) { _ in "application/json" }
