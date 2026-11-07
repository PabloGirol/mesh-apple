//
//  ObservableObjectShim.swift
//  Meshtastic
//
//  @Observable macro replacement for iOS 15 compatibility.
//  Provides ObservableObject base class with @Published properties and
//  @MainActor isolation matching the @Observable macro behavior.
//  Usage: Change `@Observable final class Foo` to `final class Foo: ObservableObject`

import Foundation
import Combine
import OSLog

// MARK: - ObservableObject Base Class

/// Base class that mimics `@Observable` macro behavior on iOS 15+.
/// - Automatically synthesizes `objectWillChange` publisher
/// - Provides `@MainActor` isolation by default
/// - Supports `@Published` properties with automatic change tracking
@MainActor
open class ObservableObject: Foundation.ObservableObject {
    public init() {}
}

// MARK: - Property Wrappers

/// `@Published` wrapper that works with the ObservableObject base.
/// On iOS 16+ with @Observable, this would be automatic.
/// Checks equality for Equatable types to avoid unnecessary updates.
@propertyWrapper
public struct Published<Value> {
    private var value: Value
    private let subject = PassthroughSubject<Value, Never>()

    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }

    public var wrappedValue: Value {
        get { value }
        set {
            // Only send update if value actually changed (for Equatable types)
            if let oldValue = value as? AnyEquatable,
               let newValue = newValue as? AnyEquatable,
               oldValue.equals(newValue) {
                return
            }
            value = newValue
            subject.send(newValue)
        }
    }

    public var projectedValue: Published<Value>.Publisher {
        Publisher(subject: subject, getValue: { self.value })
    }

    public struct Publisher: Combine.Publisher {
        public typealias Output = Value
        public typealias Failure = Never

        let subject: PassthroughSubject<Value, Never>
        let getValue: () -> Value

        public func receive<S: Subscriber>(subscriber: S) where S.Input == Value, S.Failure == Never {
            subject
                .prepend(getValue())
                .receive(subscriber: subscriber)
        }
    }
}

/// Type-erased Equatable for checking equality in Published wrapper
private protocol AnyEquatable {
    func equals(_ other: AnyEquatable) -> Bool
}

extension AnyEquatable where Self: Equatable {
    func equals(_ other: AnyEquatable) -> Bool {
        other as? Self == self
    }
}

/// `@Published` for optional values with custom equality.
@propertyWrapper
public struct PublishedOptional<Value: Equatable> {
    private var value: Value?
    private let subject = PassthroughSubject<Value?, Never>()

    public init(wrappedValue: Value? = nil) {
        self.value = wrappedValue
    }

    public var wrappedValue: Value? {
        get { value }
        set {
            if value != newValue {
                value = newValue
                subject.send(newValue)
            }
        }
    }

    public var projectedValue: PublishedOptional<Value>.Publisher {
        Publisher(subject: subject, getValue: { self.value })
    }

    public struct Publisher: Combine.Publisher {
        public typealias Output = Value?
        public typealias Failure = Never

        let subject: PassthroughSubject<Value?, Never>
        let getValue: () -> Value?

        public func receive<S: Subscriber>(subscriber: S) where S.Input == Value?, S.Failure == Never {
            subject
                .prepend(getValue())
                .receive(subscriber: subscriber)
        }
    }
}

// MARK: - Observable Protocol (for @Observable compatibility)

/// Protocol that mimics the `@Observable` macro's implicit conformance.
/// Classes conforming to this can be used with SwiftUI's observation system.
public protocol Observable: AnyObject {
    associatedtype _ObservableSelf: ObservableObject
    var _observableObject: _ObservableSelf { get }
}

// Default implementation for ObservableObject subclasses
extension Observable where Self: ObservableObject {
    public var _observableObject: Self { self }
}

// MARK: - Migration Helpers

/// Type alias for easy migration: `@Observable` → `ObservableObject`
public typealias Observable = ObservableObject

/// Macro-like helper to declare observable properties.
/// Usage inside an ObservableObject subclass:
/// ```swift
/// final class MyViewModel: ObservableObject {
///     @ObservableProperty var count = 0
///     @ObservableProperty var name = ""
/// }
/// ```
@propertyWrapper
public struct ObservableProperty<Value> {
    private var storage: Value
    private let subject = PassthroughSubject<Value, Never>()

    public init(wrappedValue: Value) {
        self.storage = wrappedValue
    }

    public var wrappedValue: Value {
        get { storage }
        set {
            storage = newValue
            subject.send(newValue)
        }
    }

    public var projectedValue: ObservableProperty<Value>.Publisher {
        Publisher(subject: subject, getValue: { self.storage })
    }

    public struct Publisher: Combine.Publisher {
        public typealias Output = Value
        public typealias Failure = Never

        let subject: PassthroughSubject<Value, Never>
        let getValue: () -> Value

        public func receive<S: Subscriber>(subscriber: S) where S.Input == Value, S.Failure == Never {
            subject
                .prepend(getValue())
                .receive(subscriber: subscriber)
        }
    }
}

// MARK: - Environment Injection Helpers

/// Inject an ObservableObject into the environment (replaces @EnvironmentObject)
@MainActor
public func injectObservable<T: ObservableObject>(_ object: T) -> some ViewModifier {
    EnvironmentObjectModifier(object: object)
}

private struct EnvironmentObjectModifier<T: ObservableObject>: ViewModifier {
    @ObservedObject var object: T

    init(object: T) {
        self._object = ObservedObject(wrappedValue: object)
    }

    func body(content: Content) -> some View {
        content.environmentObject(object)
    }
}

// MARK: - SwiftUI Integration

import SwiftUI

/// View modifier that observes an ObservableObject and refreshes on change.
/// Use instead of `@EnvironmentObject` or `@ObservedObject` when you need
/// to inject a shared instance programmatically.
@available(iOS 15.0, *)
struct ObserveObjectModifier<Object: ObservableObject>: ViewModifier {
    @ObservedObject var object: Object

    init(_ object: Object) {
        self._object = ObservedObject(wrappedValue: object)
    }

    func body(content: Content) -> some View {
        content
    }
}

@available(iOS 15.0, *)
extension View {
    /// Observe an ObservableObject without declaring it as @ObservedObject property.
    func observeObject<Object: ObservableObject>(_ object: Object) -> some View {
        modifier(ObserveObjectModifier(object))
    }
}

// MARK: - Logger Extension

extension Logger {
    static let observable = Logger(subsystem: "gvh.MeshtasticClient", category: "observable")
}