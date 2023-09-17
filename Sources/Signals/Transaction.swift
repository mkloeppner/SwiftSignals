//
//  Transaction.swift
//  
//
//  Created by Martin Klöppner.
//

import Foundation

public protocol Transaction: AnyObject {
    var modifications: [() -> Void] { get set }
    
    var updates: [() -> Void] { get set }
    
    var finished: [() -> Void] { get set }
}

/**
 * A transaction to support atomic updates on multiple signals to collect all modifications and propagation calls.
 */
public class SignalTransaction: Transaction {
    
    public var modifications: [() -> Void] = []
    
    /**
    * The context notifications for recalculating the depenend contexts
    */
    public var updates: [() -> Void] = []
    
    public var finished: [() -> Void] = []
    
    /**
     * Commits the changes of the transactions and notifies effects and computed
     */
    internal func commit() {
        for mod in modifications {
            mod()
        }
        
        for update in updates {
            update()
        }
        
        for finish in finished {
            finish()
        }
    }
    
}

public func atomic(fn: @escaping (_ tx: Transaction) -> Void) -> Void {
    let transaction = SignalTransaction()
    fn(transaction)
    transaction.commit()
}
