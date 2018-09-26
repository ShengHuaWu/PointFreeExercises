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

func predecessor(_ nat: NatureNumber) -> NatureNumber? {
    switch nat {
    case .zero:
        return nil
    case let .successor(predecessor):
        return predecessor
    }
}

func + (_ lhs: NatureNumber, _ rhs: NatureNumber) -> NatureNumber {
    switch (lhs, rhs) {
    case (.zero, .zero):
        return .zero
    case let (.zero, .successor(number)):
        return .successor(number)
    case let (.successor(number), .zero):
        return .successor(number)
    case let (.successor(left), .successor(right)):
        var copy = NatureNumber.successor(right)
        var result = NatureNumber.successor(left)
        while let predecessor = predecessor(copy) {
            result = .successor(result)
            copy = predecessor
        }
        return result
    }
}

func * (_ lhs: NatureNumber, _ rhs: NatureNumber) -> NatureNumber {
    switch (lhs, rhs) {
    case (.zero, .zero), (.zero, .successor), (.successor, .zero):
        return .zero
    case let (.successor(left), .successor(right)):
        var copy = right
        var result = NatureNumber.successor(left)
        while let predecessor = predecessor(copy) {
            result = result + .successor(left)
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

//three + two
//two + three
//one + zero
//zero + three
//
//three * two
//two * three

//three > two
//two > three
//one < zero
//zero > zero
//
//min(three, two)
//max(three, one)
