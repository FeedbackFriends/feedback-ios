import Foundation

/// Anything that provides access to an Info.plist file (or a mocked one)
public protocol InfoDictionaryOwner {
    func object(forInfoDictionaryKey key: String) -> Any?
}

public extension InfoDictionaryOwner {
    /// Returns an `InfoPlist` with a set of keys. Keys can be any object, the object itself is
    /// used to define keys and key types.
    /// - Parameter withKeys: The `Keys` object
    /// - Returns: An `InfoPlist`
    func infoPlist<T>(withKeys: T.Type) -> InfoPlist<T> {
        InfoPlist(owner: self, keys: T.self)
    }
}

extension Bundle: InfoDictionaryOwner {}

@dynamicMemberLookup
/// A warpper around an info plist, the generic `Keys` are used to provide types and key names
/// for the fields in the info.plist file.
public struct InfoPlist<Keys> {
    private let owner: InfoDictionaryOwner
    internal init(owner: InfoDictionaryOwner, keys: Keys.Type) {
        self.owner = owner
    }
    
    /// Returns an unsafe version of the info plists that will cause fatal errors when requesting keys that
    /// aren't present.
    public var unsafe: UnsafeInfoPlist<Keys> {
        UnsafeInfoPlist(wrapped: self)
    }
    
    public subscript<T>(dynamicMember member: KeyPath<Keys, T>) -> T? {
        owner.value(for: String(String(describing: member).split(separator: ".").last!))
    }
    
    public subscript<T>(dynamicMember member: KeyPath<Keys, T>) -> T? where T: RawRepresentable, T.RawValue == String {
        owner.value(for: String(String(describing: member).split(separator: ".").last!))
    }
}

@dynamicMemberLookup
/// This is a wrapper around an `InfoPlist` but it force unwraps members.
public struct UnsafeInfoPlist<Keys> {
    private let wrapped: InfoPlist<Keys>
    internal init(wrapped: InfoPlist<Keys>) {
        self.wrapped = wrapped
    }
    
    public subscript<T>(dynamicMember member: KeyPath<InfoPlist<Keys>, T?>) -> T {
        guard let forceUnwrapped = wrapped[keyPath: member] else {
            fatalError("Attemped to force unwrap \(member) in UnsafeInfoPlist")
        }
        return forceUnwrapped
    }
    
    public subscript<T>(dynamicMember member: KeyPath<InfoPlist<Keys>, T?>) -> T where T: RawRepresentable, T.RawValue == String {
        guard let forceUnwrapped = wrapped[keyPath: member] else {
            fatalError("Attemped to force unwrap \(member) in UnsafeInfoPlist")
        }
        return forceUnwrapped
    }
}

// ---- BELOW THIS LINE IS ONLY INTERNAL PLUMBING ----

extension InfoDictionaryOwner {
    func value<T>(for key: String) -> T? where T: RawRepresentable, T.RawValue == String {
        value(for: key).flatMap { (string: String) in
            T(rawValue: string)
        }
    }
    
    func value<T>(for key: String) -> T? {
        switch T.self {
        case is URL.Type:
            return url(for: key) as? T
        case is any RawRepresentable<String>.Type:
            return value(for: key)
        default:
            return self.object(forInfoDictionaryKey: key) as? T
        }
    }
    
    func url(for key: String) -> URL? {
        value(for: key).flatMap { (string: String) in
            URL(string: "https://\(string)")
        }
    }
}


