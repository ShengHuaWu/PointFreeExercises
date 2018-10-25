enum Node {
    indirect case el(String, [(String, String)], [Node], Bool)
    case text(String)
}

/*
 <header>
 <h1>Point-Free</h1>
 <p id="blurb">
 Functional programming in Swift. <a href="/about">Learn more</a>!
 </p>
 <img src="https://pbs.twimg.com/profile_images/907799692339269634/wQEf0_2N_400x400.jpg" width="64" height="64">
 </header>
*/

Node.el("header", [], [
    .el("h1", [], [.text("Point-Free")], false),
    .el("p", [("id", "blurb")], [
        .text("Functional programming in Swift."),
        .el("a", [("href", "/about")], [
            .text("Learn more")
            ], false),
        .text("!")
        ], false),
    .el("img", [("src", "https://pbs.twimg.com/profile_images/907799692339269634/wQEf0_2N_400x400.jpg"), ("width", "64"), ("height", "64")], [], true)
    ], false)

extension Node: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self = .text(value)
    }
}

Node.el("header", [], [
    .el("h1", [], ["Point-Free"], false),
    .el("p", [("id", "blurb")], [
        "Functional programming in Swift.",
        .el("a", [("href", "/about")], [
            "Learn more"
            ], false),
        "!"
        ], false),
    .el("img", [("src", "https://pbs.twimg.com/profile_images/907799692339269634/wQEf0_2N_400x400.jpg"), ("width", "64"), ("height", "64")], [], true)
    ], false)

func header(_ attrs: [(String, String)], _ children: [Node]) -> Node {
    return .el("header", attrs, children, false)
}

func h1(_ attrs: [(String, String)], _ children: [Node]) -> Node {
    return .el("h1", attrs, children, false)
}

func p(_ attrs: [(String, String)], _ children: [Node]) -> Node {
    return .el("p", attrs, children, false)
}

func a(_ attrs: [(String, String)], _ children: [Node]) -> Node {
    return .el("a", attrs, children, false)
}

func img(_ attrs: [(String, String)]) -> Node {
    return .el("img", attrs, [], true)
}

header([], [
    h1([], ["Point-Free"]),
    p([("id", "blurb")], [
        "Functional programming in Swift.",
        a([("href", "/about")], [
            "Learn more"
            ]),
        "!"
        ]),
    img([("src", "https://pbs.twimg.com/profile_images/907799692339269634/wQEf0_2N_400x400.jpg"), ("width", "64"), ("height", "64")])
    ])

func header(_ children: [Node]) -> Node {
    return header([], children)
}

func h1(_ children: [Node]) -> Node {
    return h1([], children)
}

header([
    h1(["Point-Free"]),
    p([("id", "blurb")], [
        "Functional programming in Swift.",
        a([("href", "/about")], [
            "Learn more"
            ]),
        "!"
        ]),
    img([("src", "https://pbs.twimg.com/profile_images/907799692339269634/wQEf0_2N_400x400.jpg"), ("width", "64"), ("height", "64")])
    ])

func id(_ value: String) -> (String, String) {
    return ("id", value)
}

func href(_ value: String) -> (String, String) {
    return ("href", value)
}

func src(_ value: String) -> (String, String) {
    return ("src", value)
}

func width(_ value: Int) -> (String, String) {
    return ("width", "\(value)")
}

func height(_ value: Int) -> (String, String) {
    return ("height", "\(value)")
}

let html = header([
    h1(["Point-Free"]),
    p([id("blurb")], [
        "Functional programming in Swift.",
        a([href("/about")], [
            "Learn more"
            ]),
        "!"
        ]),
    img([src("https://pbs.twimg.com/profile_images/907799692339269634/wQEf0_2N_400x400.jpg"), width(64), height(64)])
    ])

func render(_ node: Node) -> String {
    switch node {
    case let .el(tag, attrs, children, isVoid):
        let formattedChildren = children.map(render).joined(separator: "")
        if attrs.isEmpty {
            return "<\(tag)>\(formattedChildren)</\(tag)>"
        } else {
            let formattedAttrs = attrs.map{ key, value in "\(key)=\"\(value)\"" }.joined(separator: " ")
            
            guard !isVoid else {
                return "<\(tag) \(formattedAttrs)>"
            }
            
            return "<\(tag) \(formattedAttrs)>\(formattedChildren)</\(tag)>"
        }
    case let .text(value):
        return value
    }
}

print(render(html))

//import WebKit
//
//let webView = WKWebView(frame: .init(x: 0, y: 0, width: 320, height: 480))
//webView.loadHTMLString(render(html), baseURL: nil)
//
//import PlaygroundSupport
//PlaygroundPage.current.liveView = webView
