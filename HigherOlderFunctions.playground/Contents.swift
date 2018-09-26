import Foundation

func curryThreeArgs<A, B, C, D>(_ f: @escaping (A, B, C) -> D) -> (A) -> (B) -> (C) -> D {
    return { a in { b in { c in f(a, b, c) } } }
}

func exampleFunc(a: Int, b: Int, c: Int) -> Int {
    return a + b + c
}

exampleFunc(a:b:c:)
let example = curryThreeArgs(exampleFunc(a:b:c:))
example(10)(5)(1)

func curry<A, B, C>(_ f: @escaping (A, B) -> C) -> (A) -> (B) -> C {
    return { a in { b in f(a, b) } }
}

func uncurry<A, B, C>(_ f: @escaping (A) -> (B) -> C) -> (A, B) -> C {
    return { a, b in return f(a)(b) }
}

String.init(data:encoding:)
let curried = curry(String.init(data:encoding:))
let uncurried = uncurry(curried)
