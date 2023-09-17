//
//  MutableSignal.swift
//  
//
//  Created by Martin Klöppner.
//

import Foundation

/**
 * A mutable signal represents a value observed by contexts.
 *
 *The contexts will be notified once MutableSignal will be mutated.
 */
public class MutableSignal<T>: Signal<T> {
    
    /**
     * Mutates the signal and notifies the contexts the signal is being used at.
     *
     * This will also trigger all computed signals or effects that are using this signal.
     */
    public func mutate(_ value: T, _ transaction: Transaction? = nil) {
        self.executeMutation(value, transaction)
    }
    
    internal func executeMutation(_ value: T, _ transaction: Transaction? = nil) {
        if let transaction = transaction {
            transaction.modifications.append {
                self.value = value
            }
            
            transaction.updates.append {
                for ctx in self.observers {
                    ctx.notify()
                }
            }
            
            transaction.finished.append {
                for ctx in self.observers {
                    ctx.notified()
                }
            }
        } else {
            self.value = value
            for ctx in self.observers {
                ctx.notify()
            }
            for ctx in self.observers {
                ctx.notified()
            }
        }
        self.objectWillChange.send()
    }
}

extension MutableSignal where T: Equatable {
    
    public func mutate(_ value: T, _ transaction: Transaction? = nil) {
        if (self.value == value) {
            return
        }
        
        self.executeMutation(value, transaction)
    }
}

