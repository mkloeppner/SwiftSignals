//
//  Signal.swift
//  
//
//  Created by Martin Klöppner.
//

import Foundation

public protocol Observable {
    associatedtype T
    
    func fn(_ ctx: any Observer) -> T
}

/**
 * A signal represents a value that is observed by different contexts.
 */
public class Signal<T>: ObservableObject, Observable {
    public typealias T = T
    
    public let uuid: String = UUID().uuidString
    /**
     *  All contexts that using the signal.
     *  These contexts need to be updated if the signal changes.
     */
    public var observers: [Observer] = []
    
    /**
     * The current value that the signal represents
     */
#if os(iOS)
    @Published public var value: T 
#else
    public var value: T
#endif
    
    
    public init(_ value: T) {
        self.value = value
    }
    
    public func update(_ value: T) {
        self.executeUpdate(value)
    }
    
    internal func executeUpdate(_ value: T) {
        self.value = value
        
        for ctx in self.observers {
            ctx.notify()
        }
        
        self.objectWillChange.send()
    }
    
    /**
     * Returns the value of the signal for calculation.
     *
     * Its purpose is that it assigns the context of computed() or effect() when being used
     * so that the contexts can be updated when the signal value changes.
     */
    public func fn(_ ctx: any Observer) -> T {
        // If the context is already added, do not add again.
        if !self.observers.contains(where: { iteratedCtx in
            return iteratedCtx === ctx
        }) {
            self.observers.append(ctx)
        }
        return self.value
    }
}

extension Signal where T: Equatable {
    func update(_ value: T) {
        if (self.value != value) {
            self.executeUpdate(value)
        }
    }
}

extension Signal: Equatable where T: Equatable {
    public static func == (lhs: Signal<T>, rhs: Signal<T>) -> Bool {
        return lhs.value == rhs.value
    }
}
