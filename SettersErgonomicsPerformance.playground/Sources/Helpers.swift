precedencegroup ForwardApplication {
    associativity: left
}

infix operator |>: ForwardApplication
public func |> <A, B>(_ a: A, _ f: @escaping (A) -> B) -> B {
    return f(a)
}

precedencegroup ForwardComposition {
    associativity: left
    higherThan: ForwardApplication
}

infix operator >>>: ForwardComposition
public func >>> <A, B, C>(_ f: @escaping (A) -> B, _ g:@escaping (B) -> C) -> (A) -> C {
    return { a in
        return g(f(a))
    }
}

precedencegroup BackwardComposition {
    associativity: left
}

infix operator <<<: BackwardComposition
public func <<< <A, B, C>(_ f: @escaping (B) -> C, _ g: @escaping (A) -> B) -> (A) -> C {
    return { a in
        return f(g(a))
    }
}

infix operator <>: ForwardComposition
public func <> <A>(_ f: @escaping (A) -> A, _ g: @escaping (A) -> A) -> (A) -> A {
    return f >>> g
}


public func map<A, B>(_ f: @escaping (A) -> B) -> ([A]) -> [B] {
    return { array in
        return array.map(f)
    }
}

public func map<A, B>(_ f: @escaping (A) -> B) -> (A?) -> B? {
    return { a in
        switch a {
        case let .some(value):
            return f(value)
        case .none:
            return nil
        }
    }
}

prefix operator ^
public prefix func ^ <Value, Root>(_ kp: WritableKeyPath<Root, Value>) -> (@escaping (inout Value) -> Void) -> (inout Root) -> Void {
    return { update in
        return { root in
            update(&root[keyPath: kp])
        }
    }
}

public prefix func ^ <Value, Root>(_ kp: WritableKeyPath<Root, Value>) -> (@escaping (Value) -> Value) -> (Root) -> Root {
    return { update in
        return { root in
            var copy = root
            copy[keyPath: kp] = update(copy[keyPath: kp])
            return copy
        }
    }
}

public typealias Setter<A, B, S, T> = (@escaping (A) -> B) -> (S) -> T

public func over<A, B, S, T>(_ setter: Setter<A, B, S, T>, _ f: @escaping (A) -> B) -> (S) -> T {
    return setter(f)
}

public func set<A, B, S, T>(_ setter: Setter<A, B, S, T>, _ value: B) -> (S) -> T {
    return over(setter) { _ in value }
}
