# Swift Signals

Signals is a pattern that allows for simple reactive coding by bringing observability to variables.

Other then Swift Combine, Swift Signals does not rely on streaming concepts Subjects, Subscribers or Publishers. 

Instead Signals act as variables to allow turning imperative written code into reactive code by wrapping variables into closures. 

Here is an example: 

```swift
var a = 3                              let a = Signal(3)
var b = 5                              let b = MutableSignal(5)
var c = a + b                          let c = computed { ctx in a.fn(ctx) + b.fn(ctx) }
// c = 8                               // c = 8
b = 10                                 b.mutate(10)
// c = 8 still because c is not        // c = 13, computed signal changes
// recalculated after b set
```

# Features

- Signals
- Mutating Signals
- Atomic updates
- Computed properties
- Effects
- Gotchas

## Signals

A signal acts as a variable and must have a default value.
The signal is a generic type, which infers its type from the constructor. 
By default a signal is immutable. Mutable Signals will allow for changing values.

```swift
let signal = Signal(1) // Singal<Int>
```

Signals allow to access their value using a context. You can access context by utilizing one of the context functions such as [computed](#computed-properties) or [effects](#effects)

```swift
let signal = Signal(1) // Singal<Int>
effect { ctx in print("Hello \(signal.fn(ctx))"} // Prints "Hello 1"
```

## Mutating Signals 

A mutable signal acts as a variable with observation. 
Mutable signals allow changing their values over time with calling the mutate function.

```swift
let signal = MutableSignal(1)
signal.mutate(5)
```

## Atomic updates

Swift Signal allows for atomic updates. In atomic updates, computations and effects are only calculated and propagated after all signals in the atomic transaction are updated. 

```swift
let a = MutableSignal(3)
let b = MutableSignal(5)
let c = computed { ctx in a.fn(ctx) + b.fn(ctx) }

effect { ctx in
  print( "Result \(c.fn(ctx))" )
}
                                                  atomic { tx in
a.mutate(5)                                         a.mutate(5, tx)
b.mutate(1)                                         b.mutate(1, tx)
                                                  }
// Outputs                              
// Result 8 // Result initial state               // Result 8 // Initial state
// Result 10 // Intermediate result               // Result 6 // End result
// Result 6 // End result
```


## Computed properties

Computed properties are variables that are calculated from various other signals.
They need to be recalculated whenether one of their calculation signals change.

```swift
let a = MutableSignal(1)
let b = MutableSignal(1)
let computed = computed { ctx in a.fn(ctx) + b.fn(ctx) }
```
Computed properties can return any type. Their type does not neccessarily derive from the computed signals. Computed infers the type from the return value.
See an example that derives a String from various integers.


```swift
let amount = MutableSignal(1)
let amountDescription = computed { ctx in
  if a.fn(ctx) > 500 {
      return "High amount"
  }
  return "Low amount"
}
```

## Effects
Effects are operations that run whenether a used signal inside the effect closure changes. 

```swift
let signal = MutableSignal(1) // Singal<Int>
effect { ctx in print("Hello \(signal.fn(ctx))"} // Prints "Hello 1"
signal.mutate(3) // Effect is called, Prints "Hello 1"
signal.mutate(6) // Effect is called, Prints "Hello 6"
signal.mutate(7) // Effect is called, Prints "Hello 7"
```

## Advanced
Signal provides a function `fn(_ ctx: Context)` that allows to access the variable. This function registers the signal to the given context and notifies update to it, everytime the signal value changes.

This allows to hook in custom implementation of context functions to implement your own change detection and update logic. In this case you need to progagate changes yourself.

```swift
class UpdateMyState: Context {
   override func update() {
      print("Updated")
   }
}
        
let signal = MutableSignal(1)
let value = signal.fn(UpdateMyState())
signal.mutate(3)
```

> **Do not access** value directy **unless** you create your own Signal context and **want to manage change detection** on your own.
> Accessing the value directly bypasses the change detections


## Gotchas

Some common pitfalls working with Signals: 

### Effects mutating signals

When mutating a signal in a effect that the effect subscribes too an endless cycle starts. 
A cycle detection will be added in the next release.

```swift
let signal = MutableSignal(1)
effect { ctx in
    let oldSignalValue = signal.fn(ctx) // Observes this effect to signal variable 
    signal.mutate(oldSignalValue + 1) // Mutating signal variable now causes endless updates
    print("Result \(signal.fn(ctx))")
}
signal.mutate(15)
```

### Missing passing transaction in atomic operation

Right now the transaction from atomic call needs to be passed. 
We are looking into alternative syntax that does not require this.

```swift
let signal = MutableSignal(1)
let signal2 = MutableSignal(2)

atomic { tx in                  
    signal.mutate(5) // Error missing tx in method call 
    signal2.mutate(3, tx) // call signal.mutate(value, tx) on all mutations within atomic
}
```


