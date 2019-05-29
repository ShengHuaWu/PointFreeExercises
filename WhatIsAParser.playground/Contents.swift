import Foundation

struct Parser<A> {
    let run: (inout Substring) -> A?
}

extension Parser {
    func run(_ str: String) -> (match: A?, rest: Substring) {
        var str = str[...]
        let match = self.run(&str)
        return (match, str)
    }
}

let char = Parser<Character> { str -> Character? in
    func contains(_ char: Character) -> Bool {
        return char.unicodeScalars.contains(where: { CharacterSet.letters.contains($0) })
    }

    let prefix = str.prefix(while: contains(_:))
    guard let match = prefix.first else { return nil }

    str.removeFirst()

    return match
}


char.run("42")
char.run("a")
char.run("Blob is a good man")

let whitespace = Parser<Void> { str in
    str = str.split(separator: " ").joined()[...]
}

whitespace.run("Blob is a very nice guy.")

let int = Parser<Int> { str in
    var prefix = str.prefix(while: { $0.isNumber || $0 == "-" })
    if prefix.last == "-" {
        prefix.removeLast()
    }
    
    guard let int = Int(prefix) else { return nil }
    str = str[prefix.endIndex...]
    return int
}

int.run("123")
int.run("-123")
int.run("-123-abc")

func toInout<A>(_ f: @escaping (A) -> A) -> (inout A) -> Void {
    return { a in
        a = f(a)
    }
}

func fromInout<A>(_ f: @escaping (inout A) -> Void) -> (A) -> A {
    return { a in
        var copy = a
        f(&copy)
        return copy
    }
}
