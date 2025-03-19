// The Swift Programming Language
// https://docs.swift.org/swift-book

/// A protocol representing a type-level list
protocol TypeList {
    /// The type of the first element in the list
    associatedtype Head

    /// The type of the rest of the list
    associatedtype Tail: TypeList

    /// The length of the list at the type level
    static var length: Int { get }
}

/// A type-level list with at least one element
struct Cons<H, T: TypeList>: TypeList {
    typealias Head = H
    typealias Tail = T

    static var length: Int { 1 + T.length }
}

/// An empty type-level list
struct Nil: TypeList {
    typealias Head = Never
    typealias Tail = Self

    static var length: Int { 0 }
}

/// A protocol for handling types in a type-level list
protocol TypeHandler {
    associatedtype T
    func invoke()
}

/// A protocol for handling values in a type-level list
protocol ValueHandler {
    associatedtype T
    func invoke(_ value: T)
}

/// Extension to add type iteration capabilities to TypeList
extension TypeList {
    /// Iterate over each type in the list
    static func forEachType<H: TypeHandler>(_ handler: inout H) where H.T == Head {
        handler.invoke()
        Tail.forEachType(&handler)
    }
}

/// Extension to add value iteration capabilities to TypeList
extension TypeList {
    /// Iterate over each value in the list
    static func forEachValue<H: ValueHandler>(_ handler: inout H, _ head: Head, _ tail: Tail)
    where H.T == Head {
        handler.invoke(head)
        Tail.forEachValue(&handler, tail)
    }
}

/// Extension to add base case for Nil type iteration
extension Nil {
    static func forEachType<H: TypeHandler>(_ handler: inout H) {}
    static func forEachValue<H: ValueHandler>(_ handler: inout H, _ head: Never, _ tail: Nil) {}
}

/// Extension to add list operations to TypeList
extension TypeList {
    /// Push a new type to the front of the list
    typealias PushFront<T> = Cons<T, Self>
}

/// Extension to add concatenation to TypeList
extension TypeList {
    /// Concatenate two type lists
    typealias Concat<Other: TypeList> = Cons<Head, Tail.Concat<Other>>
}

/// Extension to add concatenation base case for Nil
extension Nil {
    typealias Concat<Other: TypeList> = Other
}

/// Extension to add reverse operation to TypeList
extension TypeList {
    /// Reverse the type list
    typealias Reverse = _Reverse<Nil>

    /// Internal helper for reversing type lists
    typealias _Reverse<Acc: TypeList> = Tail._Reverse<Cons<Head, Acc>>
}

/// Extension to add reverse base case for Nil
extension Nil {
    typealias _Reverse<Acc: TypeList> = Acc
}

// Example usage:
/*
// Define some types to work with
struct A {}
struct B {}
struct C {}

// Create type lists
typealias List1 = Cons<A, Cons<B, Cons<C, Nil>>>
typealias List2 = List1.Reverse
typealias List3 = List1.Concat<List2>
typealias List4 = List3.PushFront<Int>

// Type handler example
struct PrintType: TypeHandler {
    typealias T = Any
    func invoke() {
        print(T.self)
    }
}

// Value handler example
struct PrintValue: ValueHandler {
    typealias T = Any
    func invoke(_ value: T) {
        print(value)
    }
}
*/
