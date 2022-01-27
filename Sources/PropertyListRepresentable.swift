import Foundation

// TODO: do this encoding using a custom plist-encoder instead of this hackery
public protocol PropertyListRepresentable {
    init(propertyList: Any) throws
    var propertyListValue: Any { get throws }
}

// Default implementation of PropertyListRepresentable for objects that are Decobable
public extension PropertyListRepresentable where Self: Decodable {
    init(propertyList: Any) throws {
        let data = try PropertyListSerialization.data(fromPropertyList: propertyList, format: .binary, options: 0)
        let dec = PropertyListDecoder()
        self = try dec.decode(Self.self, from: data)
    }
}

// Default implementation of PropertyListRepresentable for objects that are Encodable
public extension PropertyListRepresentable where Self: Encodable {
    var propertyListValue: Any {
        get throws {
            // Encode to plist, decode :(
            // We can copy https://github.com/apple/swift-corelibs-foundation/blob/main/Darwin/Foundation-swiftoverlay/PlistEncoder.swift
            // to fix this, just not slow enough afaik
            let data = try PropertyListEncoder().encode(self)
            return try PropertyListSerialization.propertyList(from: data, format: nil)
        }
    }
}

