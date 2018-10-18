func zip2<A, B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
    var result: [(A, B)] = []
    (0 ..< min(xs.count, ys.count)).forEach { idx in result.append((xs[idx], ys[idx])) }
    return result
}

let xs = [1, 2, 3]
let ys = ["one", "two", "three"]
zip2(xs, ys)


func zip2<A, B, C>(with f: @escaping (A, B) -> C) -> ([A], [B]) -> [C] {
    return {
        zip2($0, $1).map(f)
    }
}

zip2(with: +)(xs, [7, 8, 9])

func unpack<A, B, C>(_ a: A, _ tuple: (B, C)) -> (A, B, C) {
    return (a, tuple.0, tuple.1)
}

func zip3<A, B, C>(_ xs: [A], _ ys: [B], _ zs: [C]) -> [(A, B, C)] {
    return zip2(xs, zip2(ys, zs)).map(unpack)
}

let zs = ["a", "b", "c"]
zip3(xs, ys, zs)

let ws = [0]

Array(zip(xs, zip(ys, ws)))
Array(zip(zip(xs, ys), ws))

func unzip2<A, B>(_ seq: [(A, B)]) -> ([A], [B]) {
    var xs: [A] = []
    var ys: [B] = []
    
    seq.forEach { element in
        xs.append(element.0)
        ys.append(element.1)
    }
    
    return (xs, ys)
}

enum Result<A, E> {
    case success(A)
    case failure(E)
}

func zip2<A, B, E>(_ r1: Result<A, E>, _ r2: Result<B, E>) -> Result<(A, B), E> {
    switch (r1, r2) {
    case let (.success, .failure(err)):
        return .failure(err)
    case let (.failure(err), .success):
        return .failure(err)
    case let (.failure(e1), .failure):
        return .failure(e1)
    case let (.success(a), .success(b)):
        return .success((a, b))
    }
}

let r1: Result<Int, Void> = .success(1)
let r2: Result<String, Void> = .success("one")
zip2(r1, r2)


struct Func<R, A> {
    let apply: (R) -> A
}

func zip2<A, B, R>(_ f1: Func<R, A>, _ f2: Func<R, B>) -> Func<R, (A, B)> {
    return Func { r in
        return (f1.apply(r), f2.apply(r))
    }
}

struct F3<A> {
    let run: (@escaping (A) -> Void) -> Void
}

func map<A, B>(_ f: @escaping (A) -> B) -> (F3<A>) -> F3<B> {
    return { f3a in
        return F3 { callback in
            f3a.run { a in
                callback(f(a))
            }
        }
    }
}

import Foundation

func zip2<A, B>(_ fa: F3<A>, _ fb: F3<B>) -> F3<(A, B)> {
    return F3 { callback in
        var a: A?
        var b: B?
        let queue = DispatchQueue(label: "f3")
        
        fa.run { _a in
            queue.sync {
                a = _a
                if let b = b { callback((_a, b)) }
            }
        }
        
        fb.run { _b in
            queue.sync {
                b = _b
                if let a = a { callback((a, _b)) }
            }
        }
    }
}

func zip2<A, B, C>(with f: @escaping (A, B) -> C) -> (F3<A>, F3<B>) -> F3<C> {
    return { (fa, fb) in
        return map(f)(zip2(fa, fb))
    }
}

struct F4<A, R> {
    let run: (@escaping (A) -> R) -> R
}

func zip2<A, B, R>(_ fa: F4<A, R>, _ fb: F4<B, R>) -> F4<(A, B), R> {
    fatalError()
}

func zip2<A>(_ xs: [A?]) -> [A]? {
    var result: [A] = []
    for x in xs {
        guard let a = x else { return nil }
        
        result.append(a)
    }
    
    return result
}
