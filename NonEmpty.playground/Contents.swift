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

let xs: NonEmpty<Set<Int>> = NonEmpty(head: 1, tail:[2, 3])
xs.contains(3)
xs.contains(10)
