import SwiftUI

public extension Binding {
    func safeBinding<T>(defaultValue: T) -> Binding<T> where Value == Optional<T> {
        .init {
            self.wrappedValue ?? defaultValue
        } set: { newValue in
            self.wrappedValue = newValue
        }
    }
    func unwrapped<T>() -> Binding<T> where Value == Optional<T> {
        .init {
            self.wrappedValue!
        } set: { newValue in
            self.wrappedValue = newValue
        }
    }
}

public extension Binding where Value == String? {
    
    func asNonOptional(defaultValue: String = "") -> Binding<String> {
        Binding<String>(
            get: { self.wrappedValue ?? defaultValue },
            set: { newValue in self.wrappedValue = newValue.isEmpty ? nil : newValue }
        )
    }
}
