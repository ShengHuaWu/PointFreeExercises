import Foundation

let cvv = """
1,2,3,4
5,6,7,8
9,0,1,2
"""

cvv
    .split(separator: "\n")
    .flatMap { $0.split(separator: ",") }
    .compactMap { Int($0) }
    .reduce(0, +)

// The difference between `map` & `flatMap` on optional
// is `flatMap` unwraps the value but `map` doesn't
let int1: Int? = 5
let f = int1.flatMap { _ in Optional(10) } // f is Int?
let m = int1.map { _ in Optional(10) } // m is Int??
