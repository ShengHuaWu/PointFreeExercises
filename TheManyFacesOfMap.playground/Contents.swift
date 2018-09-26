func map<K, V, W>(_ f: @escaping (V) -> W) -> ([K: V]) -> [K: W] {
    return { dictionary in
        return dictionary.mapValues(f)
    }
}

let d1 = ["0": 0, "1": 1]
let d2 = map { $0 + 1 }(d1)
d2

//return { dictionary in
//    return dictionary.mapValues(id)
//}

//return { dictionary in
//    return dictionary |> id
//}

//return { dictionary in
//    return dictionary
//}

// return { $0 }

// because no order
func notMap<A, B>(_ f: @escaping (A) -> B) -> (Set<A>) -> Set<B> {
    return { set in
        return Set(set.map(f))
    }
}

let s1: Set<Int> = [1, 2, 3]
let s2 = notMap(String.init)(s1)
