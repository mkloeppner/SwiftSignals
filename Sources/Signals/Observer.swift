//
//  Context.swift
//  
//
//  Created by Martin Klöppner.
//

import Foundation

/**
 * A context of a signal is a container for computed() signals or effects to maintain the notification graph
 *
 * Signals maintain a list of context and update them on changes
 */
public protocol Observer: AnyObject {
    
    /**
     * This method is used to propagate changes to the parent contexts of signals and cause them to recalculate
     */
    func notify()
    
    /**
     * This is called when every signal updated its value
     */
    func notified()

}
