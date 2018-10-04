enum NatureNumber {
    case zero
    indirect case successor(NatureNumber)
}

extension NatureNumber: CustomStringConvertible {
    var description: String {
        return getDescription(from: self, result: 0)
    }
    
    private func getDescription(from nat: NatureNumber, result: Int) -> String {
        switch nat {
        case .zero:
            return "\(result)"
        case let .successor(predecessor):
            return getDescription(from: predecessor, result: result + 1)
        }
    }
}

extension NatureNumber {
    var predecessor: NatureNumber? {
        switch self {
        case .zero:
            return nil
        case let .successor(predecessor):
            return predecessor
        }
    }
}

func + (_ lhs: NatureNumber, _ rhs: NatureNumber) -> NatureNumber {
    switch (lhs, rhs) {
    case (.zero, .zero):
        return .zero
    case (.zero, .successor):
        return rhs
    case (.successor, .zero):
        return lhs
    case let (.successor, .successor(right)):
        return .successor(lhs) + right
    }
}

func * (_ lhs: NatureNumber, _ rhs: NatureNumber) -> NatureNumber {
    switch (lhs, rhs) {
    case (.zero, .zero), (.zero, .successor), (.successor, .zero):
        return .zero
    case let (.successor, .successor(right)):
        var copy = right
        var result = lhs
        while let predecessor = copy.predecessor {
            result = result + lhs
            copy = predecessor
        }
        return result
    }
}

extension NatureNumber: Comparable {
    static func < (lhs: NatureNumber, rhs: NatureNumber) -> Bool {
        switch (lhs, rhs) {
        case (.zero, .zero):
            return false
        case (.zero, .successor):
            return true
        case (.successor, .zero):
            return false
        case let (.successor(left), .successor(right)):
            return left < right
        }
    }
}

let zero = NatureNumber.zero
let one = NatureNumber.successor(zero)
let two = NatureNumber.successor(one)
let three = NatureNumber.successor(two)

let five = three + two
assertEqual(five.description, "5")

assertEqual(three + two, two + three)
assertEqual(one + zero, zero + one)
assertEqual(zero + three, three + zero)

let six = three * two
assertEqual(six.description, "6")

assertEqual(three * two, two * three)
assertEqual(two * zero, zero * two)
assertEqual(one * three, three * one)

assertEqual(three > two, true)
assertEqual(two > three, false)
assertEqual(one < zero, false)


enum List<A> {
    case empty
    indirect case cons(A, List<A>)
}

extension List: CustomStringConvertible where A: CustomStringConvertible {
    var description: String {
        return getDescription(from: self, result: "]")
    }
    
    private func getDescription(from list: List<A>, result: String) -> String {
        switch list {
        case .empty:
            return "[" + result
        case let .cons(head, tail):
            return getDescription(from: tail, result: head.description + result)
        }
    }
}

extension List {
    mutating func append(_ element: A) {
        self = .cons(element, self)
    }
}

var xs = List<Int>.empty
xs.append(1)

extension List: ExpressibleByArrayLiteral {
    typealias ArrayLiteralElement = A

    init(arrayLiteral elements: A...) {
        if elements.isEmpty {
            self = .empty
        } else {
            var temp = List<A>.empty
            for e in elements {
                temp.append(e)
            }
            self = temp
        }
    }
}

let ys: List<Int> = [1, 2, 3]
