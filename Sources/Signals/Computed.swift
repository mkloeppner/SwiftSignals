//
//  Computed.swift
//  
//
//  Created by Martin Klöppner.
//

import Foundation

/**
 * A computed context holds a closure that returns a value that is recalculated every time signals within that closure change.
 */
internal class ComputedObserver<T>: Observer where T: Equatable {
    /**
     * A signal created for the computed closure to notify observers of the computed property
     */
    internal var signal: Signal<T>!
    
    /**
     * The closure that needs to be run every time a signal of the closure changed
     */
    internal var fn: (_ ctx: any Observer) -> T
    
    init(fn: @escaping (_: any Observer) -> T) {
        self.fn = fn
        self.signal = Signal<T>(self.fn(self))
    }
    
    /**
     * Recalculates the value of the computed signal upon notification and notifies parent contexts to recalculate too
     */
    internal func notify()  {
        // Reruns the closure with the latest updated signal values
        let newValue = self.fn(self)
        self.signal.update(newValue);
    }
    
    func notified() {
        
    }
}

/**
 * Creates a computed signal that updates every time a signal used inside the closure changes.
 */
public func computed<T>(fn: @escaping (_ ctx: Observer) -> T) -> Signal<T> where T: Equatable {
    let ctx = ComputedObserver<T>(fn: fn)
    return ctx.signal
}
