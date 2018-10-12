struct NonEmpty<C: Collection> {
    var head: C.Element
    var tail: C
}

extension NonEmpty where C: SetAlgebra {
    func contains(_ member: C.Element) -> Bool {
        var copy = tail
        copy.insert(head)
        return copy.contains(member)
    }
}

let xs: NonEmpty<Set<Int>> = NonEmpty(head: 1, tail: [2, 3])
xs.contains(3)
xs.contains(10)

extension NonEmpty where C: SetAlgebra {
    func union(_ other: NonEmpty) -> NonEmpty {
        var selfUnion = tail
        selfUnion.insert(head)
        var otherUnion = other.tail
        otherUnion.insert(other.head)
        var union = selfUnion.union(otherUnion)
        union.remove(head)
        
        return NonEmpty(head: head, tail: union)
    }
}

let ys: NonEmpty<Set<Int>> = NonEmpty(head: 3, tail: [2, 1])
ys.union(xs)
