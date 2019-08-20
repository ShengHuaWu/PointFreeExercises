func toInout<A>(_ f: @escaping (A) -> A) -> (inout A) -> Void {
    return { mutableA in
        mutableA = f(mutableA)
    }
}

func fromInout<A>(_ f: @escaping (inout A) -> Void) -> (A) -> A {
    return { a in
        var copy = a
        f(&copy)
        return copy
    }
}

func combine<State, Action>(_ first: @escaping (inout State, Action) -> Void,
                            _ second: @escaping (inout State, Action) -> Void) -> (inout State, Action) -> Void {
    return { state, action in
        first(&state, action)
        second(&state, action)
    }
}

func combine<State, Action>(_ reducers: (inout State, Action) -> Void...) -> (inout State, Action) -> Void {
    return { state, action in
        reducers.forEach { $0(&state, action) }
    }
}
