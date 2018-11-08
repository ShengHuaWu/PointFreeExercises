struct Equating<A> {
    let equate: (A, A) -> Bool
}

let intEquating: Equating<Int> = .init(equate: ==)
intEquating.equate(1, 2)

let strEquating: Equating<String> = .init(equate: ==)
strEquating.equate("hello", "hello")

struct Combining<A> {
    let combine: (A, A) -> A
}

func pair<A, B>(_ a: Combining<A>, _ b: Combining<B>) -> Combining<(A, B)> {
    return Combining { pair1, pair2 in
        return (a.combine(pair1.0, pair2.0), b.combine(pair1.1, pair2.1))
    }
}

let sum: Combining<Int> = .init(combine: +)
let product: Combining<Int> = .init(combine: *)
let p = pair(sum, product)
[(1, 1), (2, 2), (3, 3), (4, 4)].reduce((0, 1), p.combine)

extension Combining {
    func pointwise<B>(_ cb: Combining<B>) -> Combining<(A) -> B> {
        return Combining<(A) -> B> { f1, f2 in
            return { a in
                let ca = self.combine(a, a)
                return cb.combine(f1(ca), f2(ca))
            }
        }
    }
}

func array<A>(_ c: Combining<A>) -> Combining<[A]> {
    return Combining<[A]> { xs, ys in
        return zip(xs, ys).map(c.combine)
    }
}
