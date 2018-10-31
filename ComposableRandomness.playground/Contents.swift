import Darwin

struct Gen<A> {
    let run: () -> A
}

let random = Gen(run: arc4random)

random.run()

extension Gen {
    func map<B>(_ f: @escaping (A) -> B) -> Gen<B> {
        return Gen<B> {
            f(self.run())
        }
    }
}

random.map(String.init).run()

let uint64: Gen<UInt64> = Gen {
    let lower = UInt64(random.run())
    let upper = UInt64(random.run()) << 32
    return lower + upper
}

uint64.run()

func int(in range: ClosedRange<Int>) -> Gen<Int> {
    return Gen {
        var delta = UInt64(truncatingIfNeeded: range.upperBound &- range.lowerBound)
        if delta == UInt64.max {
            return Int(truncatingIfNeeded: uint64.run())
        }
        delta += 1
        let tmp = UInt64.max % delta + 1
        let upperBound = tmp == delta ? 0 : tmp
        var random: UInt64 = 0
        repeat {
            random = uint64.run()
        } while random < upperBound
        return Int(
            truncatingIfNeeded: UInt64(truncatingIfNeeded: range.lowerBound)
                &+ random % delta
        )
    }
}

int(in: -2 ... 7).run()

func zip2<A, B>(_ ga: Gen<A>, _ gb: Gen<B>) -> Gen<(A, B)> {
    return .init {
        return (ga.run(), gb.run())
    }
}

zip2(int(in: 0...10), int(in: 11...20)).run()

func zip2<A, B, C>(with f: @escaping (A, B) -> C) -> (Gen<A>, Gen<B>) -> Gen<C> {
    return { ga, gb in
        return .init {
            return f(ga.run(), gb.run())
        }
    }
}

zip2(with: { "\($0 + $1)" })(int(in: 0...10), int(in: 11...20))
    .run()

func zip3<A, B, C>(_ ga: Gen<A>, _ gb: Gen<B>, _ gc: Gen<C>) -> Gen<(A, B, C)> {
    return zip2(zip2(ga, gb), gc).map { ($0.0, $0.1, $1) }
}

zip3(int(in: 0...10), int(in: 11...20), int(in: 21...30)).run()

func zip3<A, B, C, D>(with f: @escaping (A, B, C) -> D) -> (Gen<A>, Gen<B>, Gen<C>) -> Gen<D> {
    return { ga, gb, gc in
        zip3(ga, gb, gc).map(f)
    }
}

zip3(with: { "\($0 + $1 + $2)" })(int(in: 0...10), int(in: 11...20), int(in: 21...30))
    .run()


func element<A>(of xs: [A]) -> Gen<A?> {
    return int(in: 0 ... (xs.count - 1)).map { index in
        guard !xs.isEmpty else { return nil }
        
        return xs[index]
    }
}

extension Gen {
    func array(count: Int) -> Gen<[A]> {
        return Gen<[A]> {
            Array(repeating: (), count: count).map(self.run)
        }
    }
}

int(in: 0...10).array(count: 4).run()

func frequency<A>(_ pairs: [(Int, Gen<A>)]) -> Gen<A> {
    let xs = pairs.map { (int, g) in
        g.array(count: int)
        }
        .flatMap { $0.run() }
    return .init {
        element(of: xs).map { $0! }.run()
    }
}

print(frequency([(1, Gen { 1 }), (4, Gen { 4 }), (7, Gen { 7 })]).run())
