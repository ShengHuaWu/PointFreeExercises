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

import Foundation

struct Persisting<Value> {
    let save: (String, Value) -> Void
    let fetch: (String) -> Value?
    let delete: (String) -> Void
}

extension Persisting where Value == Data {
    static let userDefault = Persisting(
        save: { key, value in
            UserDefaults.standard.set(value, forKey: key)
            UserDefaults.standard.synchronize()
    },
        fetch: { key in return UserDefaults.standard.value(forKey: key) as? Value },
        delete: { key in
            UserDefaults.standard.set(nil, forKey: key)
            UserDefaults.standard.synchronize()
    }
    )
    
    static let keychain = Persisting(
        save: { _, _ in },
        fetch: { _ in return nil },
        delete: { _ in }
    )
}

struct Converting<Entity, Value> {
    let encode: (Entity) -> Value?
    let decode: (Value) -> Entity?
}

extension Converting where Entity == String, Value == Data {
    static let data = Converting(
        encode: { $0.data(using: .utf8) },
        decode: { String(data: $0, encoding: .utf8) }
    )
}

struct Supplier: Codable {
    let id: Int
    let name: String
}

extension Converting where Entity == [Supplier], Value == Data {
    static let propertyList = Converting(
        encode: { try? PropertyListEncoder().encode($0) },
        decode: { try? PropertyListDecoder().decode(Entity.self, from: $0) }
    )
}

struct Caching<Entity, Value> {
    let persisting: Persisting<Value>
    let converting: Converting<Entity, Value>
    let key: String
}

extension Caching where Entity == String, Value == Data {
    static let username = Caching(
        persisting: .userDefault,
        converting: .data,
        key: "com.apple.app.username"
    )
    
    static let token = Caching(
        persisting: .keychain,
        converting: .data,
        key: "com.apple.app.token"
    )
    
    static let password = Caching(
        persisting: .keychain,
        converting: .data,
        key: "com.apple.app.password"
    )
}

extension Caching where Entity == [Supplier], Value == Data {
    static let recentSearchSuppliers = Caching(
        persisting: .userDefault,
        converting: .propertyList,
        key: "com.apple.app.recentSearchSuppliers"
    )
}

func save<Entity, Value>(entity: Entity, as witness: Caching<Entity, Value>) {
    guard let value = witness.converting.encode(entity) else { return }
    
    witness.persisting.save(witness.key, value)
}

func fetch<Entity, Value>(as witness: Caching<Entity, Value>) -> Entity? {
    guard let value = witness.persisting.fetch(witness.key),
        let entity = witness.converting.decode(value) else { return nil }
    
    return entity
}

func delete<Entity, Value>(as witness: Caching<Entity, Value>) {
    witness.persisting.delete(witness.key)
}

struct Cache {
    var savePassword = { save(entity: $0, as: .password) }
    var fetchPassword = { fetch(as: .password) }
    var deletePassword = { delete(as: .password) }
    
    var saveUsername = { save(entity: $0, as: .username) }
    var fetchUsername = { fetch(as: .username) }
    var deleteUsername = { delete(as: .username) }
    
    var saveToken = { save(entity: $0, as: .token) }
    var fetchToken = { fetch(as: .token) }
    var deleteToken = { delete(as: .token) }
    
    var saveRecentSearchSuppliers = { save(entity: $0, as: .recentSearchSuppliers) }
    var fetchRecentSearchSuppliers = { fetch(as: .recentSearchSuppliers) }
    var deleteRecentSearchSuppliers = { delete(as: .recentSearchSuppliers) }
}

protocol Persistent {
    associatedtype Value
    
    func save(value: Value, for key: String)
    func fetchValue(for key: String) -> Value?
    func deleteValue(for key: String)
}

extension UserDefaults: Persistent {
    typealias Value = Data
    
    func save(value: Data, for key: String) {
        set(value, forKey: key)
        synchronize()
    }
    
    func fetchValue(for key: String) -> Data? {
        return value(forKey: key) as? Data
    }
    
    func deleteValue(for key: String) {
        set(nil, forKey: key)
        synchronize()
    }
}
