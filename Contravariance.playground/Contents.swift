infix operator >>>
func >>> <A, B, C>(_ f: @escaping (A) -> B, _ g:@escaping (B) -> C) -> (A) -> C {
    return { a in
        return g(f(a))
    }
}

infix operator <<<
func <<< <A, B, C>(_ f: @escaping (B) -> C, _ g: @escaping (A) -> B) -> (A) -> C {
    return { a in
        return f(g(a))
    }
}

typealias Setter<A, B, S, T> = (@escaping (A) -> B) -> (S) -> T

func map<A, B, C, S, T>(_ f: @escaping (A) -> C) -> (@escaping Setter<A, B, S, T>) -> Setter<C, B, S, T> {
    return { setter in
        return { g in
            return setter(f >>> g)
        }
    }
}

func contraMap<A, B, C, S, T>(_ f: @escaping (C) -> B) -> (@escaping Setter<A, B, S, T>) -> Setter<A, C, S, T> {
    return { setter in
        return { g in
            return setter(f <<< g)
        }
    }
}

func contraMap<A, B, S, C, T>(_ f: @escaping (C) -> S) -> (@escaping Setter<A, B, S, T>) -> Setter<A, B, C, T> {
    return { setter in
        return { g in
            return setter(g) <<< f
        }
    }
}

func map<A, B, S, T, C>(_ f: @escaping (T) -> C) -> (@escaping Setter<A, B, S, T>) -> Setter<A, B, S, C> {
    return { setter in
        return { g in
            return setter(g) >>> f
        }
    }
}

struct PredicateSet<A> {
    let contains: (A) -> Bool
}

func union<A>(_ p1: PredicateSet<A>, _ p2: PredicateSet<A>) -> PredicateSet<A> {
    return PredicateSet { a in
        return p1.contains(a) || p2.contains(a)
    }
}

func intersect<A>(_ p1: PredicateSet<A>, _ p2: PredicateSet<A>) -> PredicateSet<A> {
    return PredicateSet { a in
        return p1.contains(a) && p2.contains(a)
    }
}

func invert<A>(_ p: PredicateSet<A>) -> PredicateSet<A> {
    return PredicateSet { a in
        return !p.contains(a)
    }
}

let p1 = PredicateSet { $0 < 10 }
let p2 = PredicateSet { $0 % 2 == 0 }
let u = union(p1, p2)
u.contains(4)
u.contains(99)

let i = intersect(p1, p2)
i.contains(4)
i.contains(1)

let notP1 = invert(p1)
notP1.contains(100)
notP1.contains(7)

extension BinaryInteger {
    var isPowerOfTwo: Bool {
        return (self > 0) && (self & (self - 1) == 0)
    }
}

extension PredicateSet {
    func contraMap<B>(_ f: @escaping (B) -> A) -> PredicateSet<B> {
        return PredicateSet<B>(contains: f >>> self.contains)
    }
}

let powerOf2: PredicateSet<Int> = PredicateSet { $0.isPowerOfTwo }
powerOf2.contains(128)
powerOf2.contains(55)
let powersOf2Minus1 = powerOf2.contraMap { $0 + 1 }
powersOf2Minus1.contains(127)
powersOf2Minus1.contains(8)

typealias ReturnTuple<A, B> = (B) -> (A, A)

func map<A, C, B>(_ f: @escaping (A) -> C) -> (@escaping ReturnTuple<A, B>) -> ReturnTuple<C, B> {
    return { g in
        return { b in
            return (f(g(b).0), f(g(b).1))
        }
    }
}

typealias ArgTuple<A, B> = (A, A) -> B

func contraMap<A, C, B>(_ f: @escaping (C) -> A) -> (@escaping ArgTuple<A, B>) -> (ArgTuple<C, B>) {
    return { g in
        return { (c1, c2) in
            return g(f(c1) ,f(c2))
        }
    }
}
