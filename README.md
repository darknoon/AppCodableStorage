# AppCodableStorage

Extends `@AppStorage` in SwiftUI to support any Codable object. I use SwiftUI for quick prototypes, and this makes it a lot easier to stay organized.

Just swap `@AppCodableStorage` for `@AppStorage` and tag your type as `PropertyListRepresentable` and you're good to go.

Like [AppStorage](https://developer.apple.com/documentation/swiftui/appstorage)

```swift
struct Config: PropertyListRepresentable {
    var username: String
    var profileColor: NSColor?
}

struct MyView: View {

  @AppCodableStorage("user") var settings = Config(username: "Steve")
    
  var body: some View {
    TextField($config.username)
    ...
  }
}
```

## Supported

- Use storage in multiple views, they automatically reflect the most recent value
- projectedValue / Bindings so you can pass a sub-object into a sub-view mutably
- Observes UserDefaults so it can interoperate with other code / `defaults write …` changes

## Outside of SwiftUI

The underlying implementation is in `DefaultsWriter`, which is useful if you have other subsystems in your app that want to write to and observe `UserDefaults` in this way. For that purpose, there is also a `DefaultsWriter.objectDidChange` `Publisher` to use when you want the updated value rather than a signal that it's about to change.

## Limitations

- Root must code as a Dictionary
- Encodes to `Data` and back

The default implementation of PlistReprestable is inelegant, but supports the same use cases as PlistEncoder, since I use PlistEncoder to first convert to Data and then decode the data.

A "better" solution would be to copy-paste most of the code from [PlistEncoder](https://github.com/apple/swift-corelibs-foundation/blob/main/Darwin/Foundation-swiftoverlay/PlistEncoder.swift) to be able to use `PlistCoder.encodeToTopLevelContainer()`, which is marked `internal` in the standard library. If it were made public, this could be much more elegant.

## Alternates considered

You can use `RawRepresentable` with the built-in `AppStorage to store Codable in a string key in `UserDefaults`. This means that your defaults is now unreadable since there is a weird string or binary data in there.

I realize Mike Ash independently made [TSUD](https://github.com/mikeash/TSUD), which does something pretty similar prior to SwiftUI.

## Warning

Do not use this to store a large amount of data! No images, unlimited amounts of text, files etc.

You should sanitize any user input to make sure that it ends up a reasonable size.
