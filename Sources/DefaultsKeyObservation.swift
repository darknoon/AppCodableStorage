import Foundation

/// API to observe UserDefaults with a `String` key (not `KeyPath`),  as `AppStorage` and `.string( forKey:)` use
extension UserDefaults {

    // Just a BS object b/c we can't use the newer observation syntax
    class UserDefaultsStringKeyObservation: NSObject {
        
        // Handler recieves the updated value from userdefaults
        fileprivate init(defaults: UserDefaults, key: String, handler: @escaping (Any?) -> Void) {
            self.defaults = defaults
            self.key = key
            self.handler = handler
            super.init()
            // print("Adding observer \(self) for keyPath: \(key)")
            defaults.addObserver(self, forKeyPath: key, options: .new, context: nil)
        }
        let defaults: UserDefaults
        let key: String
        
        // This prevents us from double-removing ourselves as the observer (if we are cancelled, then deinit)
        private var isCancelled: Bool = false

        private let handler: (Any?) -> Void
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            guard (object as? UserDefaults) == defaults else { fatalError("AppCodableStorage: Somehow observing wrong defaults") }
            let newValue = change?[.newKey]
            handler(newValue)
        }

        func cancel() {
            guard !isCancelled else { return }
            isCancelled = true
            defaults.removeObserver(self, forKeyPath: key)
        }

        deinit {
            cancel()
        }
    }
    
    func observe(key: String, changeHandler: @escaping (Any?) -> Void) -> UserDefaultsStringKeyObservation {
        return UserDefaultsStringKeyObservation(defaults: self, key: key, handler: changeHandler)
    }
}

import Combine

@available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
extension UserDefaults.UserDefaultsStringKeyObservation: Cancellable {}
