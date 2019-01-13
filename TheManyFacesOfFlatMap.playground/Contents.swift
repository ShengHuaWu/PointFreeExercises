import Foundation

func zip<A, B>(_ xs: [A], _ ys: [B]) -> [(A, B)] {
    let z = xs.map { a in
        ys.map { b in
            (a, b)
        }
    }

    let w = (0...min(xs.count, ys.count) - 1).map { i in z[i][i] }
    return w
}

let xs = [1, 2, 3, 4]
let ys = ["one", "two", "three"]
zip(xs, ys).count

enum Result<A, E> {
    case success(A)
    case failure(E)
}

extension Result {
    func map<B>(_ f: @escaping (A) -> B) -> Result<B, E> {
        switch self {
        case .success(let a):
            return .success(f(a))
        case .failure(let e):
            return .failure(e)
        }
    }
    
    func flatMap<B>(_ f: @escaping (A) -> Result<B, E>) -> Result<B, E> {
        switch self {
        case .success(let a):
            return f(a)
        case .failure(let e):
            return .failure(e)
        }
    }
    
    func zip<B>(_ r2: Result<B, E>) -> Result<(A, B), E> {
        fatalError()
    }
}

struct Func<A, B> {
    let apply: (A) -> B
}

extension Func {
    func flatMap<C>(_ f: @escaping (B) -> Func<A, C>) -> Func<A, C> {
        let g = { a in
            f(self.apply(a)).apply(a)
        }
        
        return Func<A, C>(apply: g)
    }
}
