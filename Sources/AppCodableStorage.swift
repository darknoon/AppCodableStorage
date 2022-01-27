import SwiftUI

@MainActor
@propertyWrapper
public struct AppCodableStorage<Value: PropertyListRepresentable>: DynamicProperty {
    private let triggerUpdate: ObservedObject<DefaultsWriter<Value>>
    // Uses the shared
    private let writer: DefaultsWriter<Value>
    
    public init(wrappedValue: Value, _ key: String, defaults: UserDefaults? = nil) {
        writer = DefaultsWriter<Value>.shared(defaultValue: wrappedValue, key: key, defaults: defaults ?? .standard)
        triggerUpdate = .init(wrappedValue: writer)
    }
    
    public var wrappedValue: Value {
        get { writer.state }
        nonmutating set { writer.state = newValue }
    }
    
    public var projectedValue: Binding<Value> {
        Binding(
            get: { writer.state },
            set: { writer.state = $0 }
        )
    }
}

