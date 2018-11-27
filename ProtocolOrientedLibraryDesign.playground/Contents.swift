import XCTest

struct Diff {
    static func lines(_ old: String, _ new: String) -> String? {
        return ""
    }
}

struct Diffing<A> {
    let diff: (A, A) -> (String, [XCTAttachment])?
    let from: (Data) -> A
    let data: (A) -> Data
}

struct Snapshoting<A, Snapshot> {
    let diffing: Diffing<Snapshot>
    let snapshot: (A) -> Snapshot
}

extension Diffing where A == String {
    static let lines = Diffing(
        diff: {
            guard let difference = Diff.lines($0, $1) else { return nil }
            return (
                "Diff: ...\n\(difference)",
                [XCTAttachment(string: difference)]
            )
        },
        from: { String(decoding: $0, as: UTF8.self) },
        data: { Data($0.utf8) }
    )
}

extension Snapshoting where A == String, Snapshot == String {
    static let lines = Snapshoting(diffing: .lines, snapshot: { $0 })
}
