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
