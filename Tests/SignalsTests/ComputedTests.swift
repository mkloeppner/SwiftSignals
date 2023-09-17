//
//  Computed.swift
//  
//
//  Created by Martin Klöppner.
//
import XCTest
@testable import Signals

import Foundation

final class ComputedTests: XCTestCase {
    
    func testComputedContextRunLamdbaByDefault() throws {
        var lamdbaCalled = 0
        _ = ComputedObserver(fn: { ctx in
            lamdbaCalled += 1
            return ""
        })
        XCTAssertEqual(1, lamdbaCalled)
    }
    
    func testComputedContextRunsLamdbaOnObservation() throws {
        let aSignal = Signal("test")
        var lamdbaCalled = 0
        _ = ComputedObserver(fn: { ctx in
            lamdbaCalled += 1
            return aSignal.fn(ctx)
        })
        XCTAssertEqual(1, lamdbaCalled)
    }
    
    func testComputedContextReRunsLamdbaMutation() throws {
        let aSignal = MutableSignal("test")
        var lamdbaCalled = 0
        _ = ComputedObserver(fn: { ctx in
            lamdbaCalled += 1
            return aSignal.fn(ctx)
        })
        XCTAssertEqual(1, lamdbaCalled)
        aSignal.mutate("oqekqoke")
        XCTAssertEqual(2, lamdbaCalled)
        aSignal.mutate("another")
        XCTAssertEqual(3, lamdbaCalled)
    }
    
    func testComputedContextSignalDoesNotPropagateChangesWithoutMutation() throws {
        let aSignal = MutableSignal("test")
        var lamdbaCalled = 0
        let ctx = ComputedObserver(fn: { ctx in
            lamdbaCalled += 1
            return aSignal.fn(ctx)
        })
        let context = TestContext()
        _ = ctx.signal.fn(context)
        
        XCTAssertEqual(0, context._update)
    }
    
    func testComputedContextSignalPropagateChangesWhenMutating() throws {
        let aSignal = MutableSignal("test")
        var lamdbaCalled = 0
        let ctx = ComputedObserver(fn: { ctx in
            lamdbaCalled += 1
            return aSignal.fn(ctx)
        })
        let context = TestContext()
        _ = ctx.signal.fn(context)
        aSignal.mutate("tset")
        
        XCTAssertEqual(1, context._update)
    }
    
    func testComputedContextSignalDoesNotPropagateChangesWhenMutatingWithoutChange() throws {
        let aSignal = MutableSignal("test")
        var lamdbaCalled = 0
        let ctx = ComputedObserver(fn: { ctx in
            lamdbaCalled += 1
            return aSignal.fn(ctx)
        })
        let context = TestContext()
        _ = ctx.signal.fn(context)
        aSignal.mutate("test")
        
        XCTAssertEqual(0, context._update)
    }
    
    func testComputedContextSignalDoesNotPropagateChangesWhenMutatingWithChangeButSameResult() throws {
        let aSignal = MutableSignal(1)
        var lamdbaCalled = 0
        let ctx = ComputedObserver(fn: { ctx in
            _ = aSignal.fn(ctx)
            lamdbaCalled += 1
            return "test" // Hardcoded, same result on mutation, do not propagate
        })
        let context = TestContext()
        _ = ctx.signal.fn(context)
        aSignal.mutate(5)
        
        XCTAssertEqual(0, context._update)
    }

    
}
