import Foundation

let employeesJSON = """
[
{
"id": 0,
"name": "Sheng",
"email": "shenghua@conichi.com",
"department_id": 0
},
{
"id": 1,
"name": "Joseph",
"email": "joseph@conichi.com",
"department_id": 0
},
{
"id": 2,
"name": "David",
"email": "david@conichi.com",
"department_id": null
}
]
"""

let departmentsJSON = """
[
{
"id": 0,
"name": "IT"
}
]
"""

struct Tagged<Tag, RawValue> {
    let rawValue: RawValue
}

extension Tagged: Decodable where RawValue: Decodable {
    init(from decoder: Decoder) throws {
        self.init(rawValue: try RawValue.init(from: decoder))
    }
}

extension Tagged: ExpressibleByIntegerLiteral where RawValue: ExpressibleByIntegerLiteral {
    typealias IntegerLiteralType = RawValue.IntegerLiteralType

    init(integerLiteral value: RawValue.IntegerLiteralType) {
        self.init(rawValue: RawValue.init(integerLiteral: value))
    }
}

extension Tagged: ExpressibleByUnicodeScalarLiteral where RawValue: ExpressibleByUnicodeScalarLiteral {
    typealias UnicodeScalarLiteralType = RawValue.UnicodeScalarLiteralType
    
    init(unicodeScalarLiteral value: RawValue.UnicodeScalarLiteralType) {
        self.init(rawValue: RawValue.init(unicodeScalarLiteral: value))
    }
}

extension Tagged: ExpressibleByExtendedGraphemeClusterLiteral where RawValue: ExpressibleByExtendedGraphemeClusterLiteral {
    typealias ExtendedGraphemeClusterLiteralType = RawValue.ExtendedGraphemeClusterLiteralType
    
    init(extendedGraphemeClusterLiteral value: RawValue.ExtendedGraphemeClusterLiteralType) {
        self.init(rawValue: RawValue.init(extendedGraphemeClusterLiteral: value))
    }
}

extension Tagged: ExpressibleByStringLiteral where RawValue: ExpressibleByStringLiteral {
    typealias StringLiteralType = RawValue.StringLiteralType
    
    internal init(stringLiteral value: RawValue.StringLiteralType) {
        self.init(rawValue: RawValue.init(stringLiteral: value))
    }
}

extension Tagged: Equatable where RawValue: Equatable {
    static func == (lhs: Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

extension Tagged: Comparable where RawValue: Comparable {
    static func < (lhs: Tagged<Tag, RawValue>, rhs: Tagged<Tag, RawValue>) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

struct Employee: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case departmentID = "department_id"
    }
    
    typealias ID = Tagged<Employee, Int>
    enum EmailTag {}
    typealias Email = Tagged<EmailTag, String>
    
    let id: ID
    var name: String
    var email: Email
    var departmentID: Int?
}

struct Department: Decodable {
    typealias ID = Tagged<Department, Int>
    
    let id: ID
    var name: String
}

let decoder = JSONDecoder()
let employees = try! decoder.decode([Employee].self, from: Data(employeesJSON.utf8))
let departments = try! decoder.decode([Department].self, from: Data(departmentsJSON.utf8))

let employee = employees[0]
let department = departments[0]

//employee.id == department.id

//Employee(id: 1, name: "Jessica", email: "jessica@gmail.com", departmentID: 0)

employees
    .sorted { $0.id > $1.id }


enum RealColor {
    case red
    case blue
}
enum On {}
enum Off {}

struct Light<A> {
    typealias Color = Tagged<A, RealColor>
    var color: Color
}

func turnOn() -> Light<On> {
    return Light(color: Tagged(rawValue: .red))
}

func turnOff() -> Light<Off> {
    return Light(color: Tagged(rawValue: .red))
}

func changeColor(for light: Light<On>) -> Light<On> {
    return Light(color: Tagged(rawValue: .blue))
}

turnOn()
turnOff()
//changeColor(for: turnOff())
changeColor(for: turnOn())
