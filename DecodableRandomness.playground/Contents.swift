import Foundation

struct ArbitraryDecoder: Decoder {
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        return KeyedDecodingContainer(KeyedContainer())
    }
    
    struct KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
        var codingPath: [CodingKey] = []
        var allKeys: [Key] = []
        
        func contains(_ key: Key) -> Bool {
            fatalError()
        }
        
        func decodeNil(forKey key: Key) throws -> Bool {
            return .random()
        }
        
        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
            return try T(from: ArbitraryDecoder())
        }
        
        func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
            fatalError()
        }
        
        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            fatalError()
        }
        
        func superDecoder() throws -> Decoder {
            fatalError()
        }
        
        func superDecoder(forKey key: Key) throws -> Decoder {
            fatalError()
        }
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError()
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return SingleValueContainer()
    }
    
    struct SingleValueContainer: SingleValueDecodingContainer {
        var codingPath: [CodingKey] = []
        
        func decodeNil() -> Bool {
            return .random()
        }
        
        func decode(_ type: Bool.Type) throws -> Bool {
            return .random()
        }
        
        func decode(_ type: String.Type) throws -> String {
            return Array(repeating: (), count: .random(in: 0...100))
                .map { String(UnicodeScalar(UInt8.random(in: .min ... .max))) }
                .joined()
        }
        
        func decode(_ type: Double.Type) throws -> Double {
            return .random(in: -1_000_000_000 ... 1_000_000_000)
        }
        
        func decode(_ type: Float.Type) throws -> Float {
            return .random(in: -1_000_000 ... 1_000_000)
        }
        
        func decode(_ type: Int.Type) throws -> Int {
            return .random(in: .min ... .max)
        }
        
        func decode(_ type: Int8.Type) throws -> Int8 {
            return .random(in: .min ... .max)
        }
        
        func decode(_ type: Int16.Type) throws -> Int16 {
            return .random(in: .min ... .max)
        }
        
        func decode(_ type: Int32.Type) throws -> Int32 {
            return .random(in: .min ... .max)
        }
        
        func decode(_ type: Int64.Type) throws -> Int64 {
            return .random(in: .min ... .max)
        }
        
        func decode(_ type: UInt.Type) throws -> UInt {
            return .random(in: .min ... .max)
        }
        
        func decode(_ type: UInt8.Type) throws -> UInt8 {
            return .random(in: .min ... .max)
        }
        
        func decode(_ type: UInt16.Type) throws -> UInt16 {
            return .random(in: .min ... .max)
        }
        
        func decode(_ type: UInt32.Type) throws -> UInt32 {
            return .random(in: .min ... .max)
        }
        
        func decode(_ type: UInt64.Type) throws -> UInt64 {
            return .random(in: .min ... .max)
        }
        
        func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            return try T(from: ArbitraryDecoder())
        }
    }
}

let a = ArbitraryDecoder()

try Bool.init(from: a)
try Bool.init(from: a)
try Bool.init(from: a)

try Int.init(from: a)
try Int.init(from: a)
try Int.init(from: a)

try UInt8.init(from: a)
try UInt8.init(from: a)
try UInt8.init(from: a)

try String.init(from: a)
try String.init(from: a)
try String.init(from: a)

try Date.init(from: a)
try Date.init(from: a)
try Date.init(from: a)
try Date?.init(from: a)

struct User: Decodable {
    let id: UUID
    let name: String
    let email: String
}

struct Gen<A> {
    let run: () -> A
}

import Darwin
let random = Gen(run: arc4random)

extension Gen {
    func map<B>(_ f: @escaping (A) -> B) -> Gen<B> {
        return Gen<B> { f(self.run()) }
    }
}

let uint64 = Gen<UInt64> {
    let lower = UInt64(random.run())
    let upper = UInt64(random.run()) << 32
    return lower + upper
}

func int(in range: ClosedRange<Int>) -> Gen<Int> {
    return Gen<Int> {
        var delta = UInt64(truncatingIfNeeded: range.upperBound &- range.lowerBound)
        if delta == UInt64.max {
            return Int(truncatingIfNeeded: uint64.run())
        }
        delta += 1
        let tmp = UInt64.max % delta + 1
        let upperBound = tmp == delta ? 0 : tmp
        var random: UInt64 = 0
        repeat {
            random = uint64.run()
        } while random < upperBound
        return Int(
            truncatingIfNeeded: UInt64(truncatingIfNeeded: range.lowerBound)
                &+ random % delta
        )
    }
}

func element<A>(of xs: [A]) -> Gen<A?> {
    return int(in: 0...(xs.count - 1)).map { idx in
        guard !xs.isEmpty else { return nil }
        return xs[idx]
    }
}

extension Gen {
    func array(count: Gen<Int>) -> Gen<[A]> {
        return Gen<[A]> {
            Array(repeating: (), count: count.run())
                .map { self.run() }
        }
    }
}

func uint8(in range: ClosedRange<UInt8>) -> Gen<UInt8> {
    return int(in: Int(range.lowerBound) ... Int(range.upperBound)).map(UInt8.init)
}

let string = uint8(in: .min ... .max)
    .map(UnicodeScalar.init)
    .map(String.init)
    .array(count: int(in: 0...100))
    .map{ $0.joined() }

let alpha = element(of: Array("abcdefghijklmnopqrstuvxcyz")).map{ $0! }

extension Gen where A == Character {
    func string(count: Gen<Int>) -> Gen<String> {
        return map(String.init).array(count: count).map{ $0.joined() }
    }
}

let randomID = int(in: 1 ... 1_000)

let namePart = alpha.string(count: int(in: 4...8))
let capitalNamePart = namePart.map{ $0.capitalized }
let randomName = Gen<String> { capitalNamePart.run() + " " + capitalNamePart.run() }
let randomEmail = Gen<String> { namePart.run() + "." + namePart.run() + "@gmail.com" }

func zip2<A, B>(_ ga: Gen<A>, _ gb: Gen<B>) -> Gen<(A, B)> {
    return Gen {
        (ga.run(), gb.run())
    }
}

func zip2<A, B, C>(with f: @escaping (A, B) -> C) -> (Gen<A>, Gen<B>) -> Gen<C> {
    return { ga, gb in
        zip2(ga, gb).map(f)
    }
}

func zip3<A, B, C>(_ ga: Gen<A>, _ gb: Gen<B>, _ gc: Gen<C>) -> Gen<(A, B, C)> {
    return zip2(ga, zip2(gb, gc)).map{ ($0, $1.0, $1.1) }
}

func zip3<A, B, C, D>(with f: @escaping (A, B, C) -> D) -> (Gen<A>, Gen<B>, Gen<C>) -> Gen<D> {
    return { zip3($0, $1, $2).map(f) }
}

let hex = element(of: Array("0123456789ABCDEF")).map{ $0! }
let uuidString = Gen<String> {
    hex.string(count: .init { 8 }).run()
        + "-" + hex.string(count: .init { 4 }).run()
        + "-" + hex.string(count: .init { 4 }).run()
        + "-" + hex.string(count: .init { 4 }).run()
        + "-" + hex.string(count: .init { 12 }).run()
}
let randomUUID = uuidString.map(UUID.init).map{ $0! }

let randomUser = zip3(with: User.init)(randomUUID, randomName, randomEmail)

print(randomUser.run())
print(randomUser.run())
print(randomUser.run())
