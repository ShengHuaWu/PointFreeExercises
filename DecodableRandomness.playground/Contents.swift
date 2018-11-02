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
    let id: Int
    let name: String
    let email: String
}

print(try User.init(from: a))
print(try User.init(from: a))
print(try User.init(from: a))
