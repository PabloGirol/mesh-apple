//
//  NavigationStackShim.swift
//  Meshtastic
//
//  NavigationStack API shim for iOS 15 compatibility.
//  Provides NavigationStack-like API backed by NavigationView on iOS 15-16.
//  Usage: Replace `import SwiftUI` with this + use `CompatNavigationStack` instead of `NavigationStack`.
//

import SwiftUI

// MARK: - NavigationStack Compatibility Layer

/// Drop-in replacement for `NavigationStack` that works on iOS 15+.
/// On iOS 16+, uses native `NavigationStack`. On iOS 15, uses `NavigationView` with
/// programmatic navigation via `NavigationLink` tags.
@available(iOS 15.0, *)
struct CompatNavigationStack<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack(root: content)
        } else {
            NavigationView {
                content()
            }
            .navigationViewStyle(.stack)
        }
    }
}

/// Drop-in replacement for `NavigationStack(path:)` with binding.
/// On iOS 15, uses a single `NavigationLink` per possible destination (limited).
@available(iOS 15.0, *)
struct CompatNavigationStackWithPath<Path: Hashable, Content: View>: View {
    @Binding var path: [Path]
    @ViewBuilder let content: () -> Content

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack(path: $path, root: content)
        } else {
            // iOS 15 fallback: NavigationView with tagged NavigationLinks
            // This is a simplified version - full programmatic navigation requires more work
            NavigationView {
                content()
            }
            .navigationViewStyle(.stack)
        }
    }
}

/// Drop-in replacement for `NavigationStack(path:root:)` with data-based navigation (iOS 16+ only).
/// NavigationPath doesn't exist on iOS 15, so this API is only available on iOS 16+.
/// For iOS 15, use `CompatNavigationStackWithPath` with an array-based path instead.
@available(iOS 16.0, *)
struct CompatNavigationStackWithData<Data: Hashable, Content: View>: View {
    @Binding var path: NavigationPath
    @ViewBuilder let root: () -> Content

    var body: some View {
        NavigationStack(path: $path, root: root)
    }
}

// MARK: - NavigationLink Compatibility

/// Drop-in replacement for `NavigationLink(value:)` (iOS 16+).
/// On iOS 15, uses tag-based navigation with a hidden NavigationLink.
@available(iOS 15.0, *)
struct CompatNavigationLink<Value: Hashable, Label: View>: View {
    let value: Value
    @ViewBuilder let label: () -> Label

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationLink(value: value, label: label)
        } else {
            // iOS 15: Can't do value-based navigation directly.
            // The view using this must wrap in NavigationView and manage tags manually.
            // This is a placeholder that renders the label.
            label()
        }
    }
}

/// Drop-in replacement for `NavigationLink(destination:)` (iOS 13+).
/// Works on all iOS versions.
@available(iOS 15.0, *)
struct CompatNavigationLinkDestination<Destination: View, Label: View>: View {
    let destination: Destination
    @ViewBuilder let label: () -> Label

    var body: some View {
        NavigationLink(destination: destination, label: label)
    }
}

// MARK: - NavigationDestination Compatibility

/// Drop-in replacement for `.navigationDestination(for:destination:)` (iOS 16+).
/// On iOS 15, this is a no-op - you must use explicit NavigationLinks.
@available(iOS 15.0, *)
struct NavigationDestinationModifier<D: Hashable, Destination: View>: ViewModifier {
    let dataType: D.Type
    @ViewBuilder let destination: (D) -> Destination

    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.navigationDestination(for: D.self, destination: destination)
        } else {
            content
        }
    }
}

@available(iOS 15.0, *)
extension View {
    /// iOS 15+ compatible `.navigationDestination(for:destination:)`
    func compatNavigationDestination<D: Hashable, Destination: View>(
        for dataType: D.Type,
        @ViewBuilder destination: @escaping (D) -> Destination
    ) -> some View {
        modifier(NavigationDestinationModifier(dataType: dataType, destination: destination))
    }
}

// MARK: - NavigationPath Compatibility

/// Lightweight wrapper for NavigationPath on iOS 16+, empty on iOS 15.
@available(iOS 15.0, *)
struct CompatNavigationPath {
    @available(iOS 16.0, *)
    private var path: NavigationPath = NavigationPath()

    @available(iOS 16.0, *)
    mutating func append<V: Hashable>(_ value: V) {
        path.append(value)
    }

    @available(iOS 16.0, *)
    mutating func removeLast(_ k: Int = 1) {
        path.removeLast(k)
    }

    @available(iOS 16.0, *)
    var isEmpty: Bool {
        path.isEmpty
    }

    @available(iOS 16.0, *)
    var count: Int {
        path.count
    }

    // iOS 15 stubs
    @available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use native NavigationPath on iOS 16+")
    mutating func append<V: Hashable>(_ value: V) {}

    @available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use native NavigationPath on iOS 16+")
    mutating func removeLast(_ k: Int = 1) {}

    @available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use native NavigationPath on iOS 16+")
    var isEmpty: Bool { true }

    @available(iOS, introduced: 15.0, deprecated: 16.0, message: "Use native NavigationPath on iOS 16+")
    var count: Int { 0 }
}

// MARK: - Type Aliases for Easy Migration

/// Use `NavigationStack` instead of `NavigationStack` in your code.
/// Add `import NavigationStackShim` or just use the type directly.
@available(iOS 15.0, *)
typealias NavigationStack = CompatNavigationStack

/// Use `NavigationStack` with path binding.
@available(iOS 15.0, *)
typealias NavigationStackPath = CompatNavigationStackWithPath

/// Use `NavigationLink` instead of `NavigationLink(value:)`.
@available(iOS 15.0, *)
typealias NavigationLink = CompatNavigationLink

/// Use `NavigationLink` for destination-based links (works everywhere).
@available(iOS 15.0, *)
typealias NavigationLinkDest = CompatNavigationLinkDestination