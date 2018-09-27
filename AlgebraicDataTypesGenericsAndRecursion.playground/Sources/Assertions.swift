public func assertEqual<A: Equatable>(_ lhs: A, _ rhs: A) -> String {
    if lhs == rhs {
        return "✅"
    } else {
        return "❌"
    }
}
