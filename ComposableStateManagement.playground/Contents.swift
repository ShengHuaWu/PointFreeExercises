func toInout<A>(_ f: @escaping (A) -> A) -> (inout A) -> Void {
    return { mutableA in
        mutableA = f(mutableA)
    }
}

func fromInout<A>(_ f: @escaping (inout A) -> Void) -> (A) -> A {
    return { a in
        var copy = a
        f(&copy)
        return copy
    }
}

func combine<State, Action>(_ first: @escaping (inout State, Action) -> Void,
                            _ second: @escaping (inout State, Action) -> Void) -> (inout State, Action) -> Void {
    return { state, action in
        first(&state, action)
        second(&state, action)
    }
}

func combine<State, Action>(_ reducers: (inout State, Action) -> Void...) -> (inout State, Action) -> Void {
    return { state, action in
        reducers.forEach { $0(&state, action) }
    }
}


import Foundation
import Combine

struct AppState {
  var count = 0
  var favoritePrimes: [Int] = []
  var activityFeed: [Activity] = []
  var loggedInUser: User? = nil

  struct Activity {
    let type: ActivityType
    let timestamp = Date()

    enum ActivityType {
      case addedFavoritePrime(Int)
      case removedFavoritePrime(Int)
    }
  }

  struct User {
    let id: Int
    let name: String
    let bio: String
  }
}

final class Store<Value, Action>: ObservableObject {
    @Published var value: Value
    let reducer: (inout Value, Action) -> Void

    init(initialValue: Value, reducer: @escaping (inout Value, Action) -> Void) {
        self.value = initialValue
        self.reducer = reducer
    }
    
    func send(_ action: Action) {
        self.reducer(&self.value, action)
    }
}

enum CounterAction {
  case decrTapped
  case incrTapped
}

func counterReducer(state: inout AppState, action: CounterAction) {
  switch action {
  case .decrTapped:
    state.count -= 1
  case .incrTapped:
    state.count += 1
  }
}

var state = AppState()
counterReducer(state: &state, action: .incrTapped)
counterReducer(state: &state, action: .decrTapped)
print(state)
