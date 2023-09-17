//
//  MutableSignalTests.swift
//  
//
//  Created by Martin Klöppner.
//

import XCTest
@testable import Signals

final class MutableSignalTests: XCTestCase {
    
    func testMutableSignalIntializesValue() throws {
        let signal = MutableSignal("test")
        XCTAssertEqual(signal.value, "test")
    }
    
    func testMutableSignalReadsValue() throws {
        let signal = MutableSignal("test")
        let context = TestContext()
        let value = signal.fn(context)
        XCTAssertEqual(value, "test")
    }
    
    func testMutableSignalSubscribesContextWhileReadingValue() throws {
        let signal = MutableSignal("test")
        let context = TestContext()
        _ = signal.fn(context)
        XCTAssertEqual(signal.observers.count, 1, "No context subscribed")
    }
    
    func testMutableSignalUpdatesValue() throws {
        let a = MutableSignal(3)
        a.mutate(1)
        XCTAssertEqual(1, a.value)
    }
    
    func testMutableSignalUpdatesValueAndReadsViaApi() throws {
        let a = MutableSignal(3)
        a.mutate(1)
        XCTAssertEqual(1, a.fn(TestContext()))
    }
    
    func testMutableSignalUpdatesContextWhenWritingAfterSubscribing() throws {
        let a = MutableSignal(3)
        let context = TestContext()
        _ = a.fn(context) // Subscribe
        a.mutate(1)
        XCTAssertEqual(context._update, 1)
        XCTAssertEqual(context._updated, 1)
    }
    
    func testMutableSignalNotUpdatesContextWhenWritingAfterSubscribingOnSameValue() throws {
        let a = MutableSignal(3)
        let context = TestContext()
        _ = a.fn(context) // Subscribe
        a.mutate(3)
        XCTAssertEqual(context._update, 0)
        XCTAssertEqual(context._updated, 0)
    }
    
    func testMutableSignalAddsMutationsToTransaction() throws {
        let a = MutableSignal(3)
        let transaction = TestTransaction()
        a.mutate(5, transaction)
        XCTAssertEqual(transaction.modifications.count, 1)
        XCTAssertEqual(transaction.updates.count, 1)
        XCTAssertEqual(transaction.finished.count, 1)
    }
    
    func testMutableSignalNotAddsMutationsToTransactionOnSameValue() throws {
        let a = MutableSignal(3)
        let transaction = TestTransaction()
        a.mutate(3, transaction)
        XCTAssertEqual(transaction.modifications.count, 0)
        XCTAssertEqual(transaction.updates.count, 0)
        XCTAssertEqual(transaction.finished.count, 0)
    }
    
}
