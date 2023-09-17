import XCTest
@testable import Signals

final class TestContext: Observer {
    var _update: Int = 0
    var _updated: Int = 0
    func notify() {
        self._update += 1
    }
    
    func notified() {
        self._updated += 1
    }
    
}

final class TestTransaction: Transaction {
    var modifications: [() -> Void] = []
    
    var updates: [() -> Void] = []
    
    var finished: [() -> Void] = []
}

struct User {
    let username: String
    let password: String
}

final class SignalsTests: XCTestCase {

}
