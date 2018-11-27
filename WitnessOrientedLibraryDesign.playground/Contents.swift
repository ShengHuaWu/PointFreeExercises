import XCTest

struct Diff {
    static func lines(_ old: String, _ new: String) -> String? {
        return ""
    }
}

struct Diffing<A> {
    let diff: (A, A) -> (String, [XCTAttachment])?
    let from: (Data) -> A
    let data: (A) -> Data
}

struct Snapshotting<A, Snapshot> {
    let diffing: Diffing<Snapshot>
    let pathExtension: String
    let snapshot: (A) -> Snapshot
    
    func pullback<B>(_ f: @escaping (B) -> A) -> Snapshotting<B, Snapshot> {
        return Snapshotting<B, Snapshot>(
            diffing: diffing,
            pathExtension: pathExtension,
            snapshot: { b in self.snapshot(f(b)) }
        )
    }
}

extension Diffing where A == String {
    static let lines = Diffing(
        diff: { old, new in
            guard let difference = Diff.lines(old, new) else {
                return nil
            }
            
            return ("Diff: ...\n\(difference)",
                [XCTAttachment(string: difference)]
            )
    },
        from: { String(decoding: $0, as: UTF8.self) },
        data: { Data($0.utf8) }
    )
}

extension Snapshotting where A == String, Snapshot == String {
    static let lines = Snapshotting(
        diffing: .lines,
        pathExtension: "txt",
        snapshot: { $0 }
    )
}

extension Snapshotting where A == Any, Snapshot == String {
    static let lines: Snapshotting = Snapshotting<String, String>.lines.pullback { any in
        var output = String()
        dump(any, to: &output)
        return output
    }
}

struct User {
    let name: String
    let email: String
}

let user = User(name: "Sheng", email: "sheng.test@gamil.com")
print(Snapshotting<Any, String>.lines.snapshot(user))

extension Snapshotting where A == URLRequest, Snapshot == String {
    static let lines: Snapshotting = Snapshotting<String, String>.lines.pullback { request in
        var output = "URL: \(request.url!.absoluteString)\n"
        output += "Method: \(request.httpMethod!) \nHeaders: \n"
        
        request.allHTTPHeaderFields?.forEach { (key, value) in
            output += "\(key): \(value)\n"
        }
        
        output += String(data: request.httpBody!, encoding: .utf8)!
        
        return output
    }
}

var request = URLRequest(url: URL(string: "https://apple.developer.com")!)
request.httpMethod = "PUT"
request.setValue("application/json", forHTTPHeaderField: "Content-Type")
request.httpBody = Data("12345567".utf8)
print(Snapshotting<URLRequest, String>.lines.snapshot(request))
