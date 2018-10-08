import Foundation

class APIManager {
    var sendRequest = sendRequest(with:)
    
    init() {}
    
    convenience init(sendRequest: @escaping (URLRequest) -> Void) {
        self.init()
        self.sendRequest = sendRequest
    }
}

extension APIManager {
    static let mock = APIManager { _ in
        print("it is a mock")
    }
}

private func sendRequest(with request: URLRequest) {
    print("send a request")
}

class DataManager {
    var fetchUser = fetchUser(with:)
    
    init() {}
    
    convenience init(fetchUser: @escaping (Int) -> Void) {
        self.init()
        self.fetchUser = fetchUser
    }
}

extension DataManager {
    static let mock = DataManager { _ in
        print("it is a mock")
    }
}

private func fetchUser(with id: Int) {
    print("fetch user info")
    let req = URLRequest(url: URL(string: "https://apple.com")!)
    Current.apiManager.sendRequest(req)
}

struct Environment {
    var apiManager = APIManager()
    var dataManager = DataManager()
}

extension Environment {
    static let mock = Environment(apiManager: .mock, dataManager: .mock)
}

var Current = Environment()
Current.dataManager.fetchUser(1)

Current.apiManager = .mock
Current.dataManager.fetchUser(1)

Current = .mock
let req = URLRequest(url: URL(string: "https://apple.com")!)
Current.apiManager.sendRequest(req)


func test() {
    print("Hello")
    return

    print("World")
}

test()
