enum Expr: Equatable {
    case int(Int)
    indirect case add(Expr, Expr)
    indirect case mul(Expr, Expr)
    case `var`
}

extension Expr: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        self = .int(value)
    }
}

func print(_ expr: Expr) -> String {
    switch expr {
    case let .int(value):
        return "\(value)"
    case let .add(lhs, rhs):
        return "(\(print(lhs)) + \(print(rhs)))"
    case let .mul(lhs, rhs):
        return "(\(print(lhs)) * \(print(rhs)))"
    case .var:
        return "x"
    }
}

func simplify(_ expr: Expr) -> Expr {
    switch expr {
    case let .add(.mul(a, b), .mul(c, d)) where a == c:
        return simplify(.mul(a, .add(b, d)))
    case let .add(.mul(a, b), .mul(c, d)) where b == d:
        return simplify(.mul(.add(a, c), b))
    case let .add(a, b) where a == .int(0):
        return b
    case let .add(a, b) where b == .int(0):
        return a
    case let .mul(a, b) where a == .int(1):
        return simplify(b)
    case let .mul(a, b) where b == .int(1):
        return simplify(a)
    case let .mul(a, b) where a == .int(0) || b == .int(0):
        return .int(0)
    case .int:
        return expr
    case .add:
        return expr
    case .mul:
        return expr
    case .var:
        return expr
    }
}

print(simplify(Expr.add(.mul(2, 3), .mul(2, 4))))
print(simplify(Expr.add(.mul(2, 3), .mul(4, 3))))

print(simplify(.mul(1, .var)))
print(simplify(.mul(.var, 1)))

print(simplify(.mul(0, .var)))
print(simplify(.mul(.var, 0)))

print(simplify(.add(0, .var)))
print(simplify(.add(.var, 0)))

func eval(_ expr: Expr, with values: [Int]) -> Int {
    switch expr {
    case let .int(value):
        return value
    case let .add(lhs, rhs):
        return eval(lhs, with: values) + eval(rhs, with: Array(values.dropFirst()))
    case let .mul(lhs, rhs):
        return eval(lhs, with: values) * eval(rhs, with: Array(values.dropFirst()))
    case .var:
        return values.first!
    }
}

eval(.add(.var, .mul(.var, .var)), with: [1, 8, 3])

func + (_ lhs: Expr, _ rhs: Expr) -> Expr {
    return .add(lhs, rhs)
}

func * (_ lhs: Expr, _ rhs: Expr) -> Expr {
    return .mul(lhs, rhs)
}

print(.var + 3)
print((.var + 3) * 5)

func varCount(_ expr: Expr) -> Int {
    switch expr {
    case .int:
        return 0
    case let .add(lhs, rhs):
        return varCount(lhs) + varCount(rhs)
    case let .mul(lhs, rhs):
        return varCount(lhs) + varCount(rhs)
    case .var:
        return 1
    }
}

varCount(.mul(.var, .add(1, .mul(.var, 8))))
varCount(.var + 3 * .var + 6 + .var)
