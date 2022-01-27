import XCTest
@testable import AppCodableStorage

let defaultsKey = "Tests_macOS_root"

let volatileDomain = "AppCodableStorage_tests_domain"

protocol DefaultValue {
    static var defaultValue: Self { get }
}

@MainActor
final class AppCodableStorageTests: XCTestCase {
    
    struct DictionaryRecord: Codable, Equatable, PropertyListRepresentable, DefaultValue {
        var foo: Double
        var bar: String
        var bash: String?
        
        static let defaultValue = DictionaryRecord(foo: 0, bar: "no")
    }

    struct MockView<Value: DefaultValue & PropertyListRepresentable> {
        @AppCodableStorage(defaultsKey) var value = Value.defaultValue
    }
    
    func resetState() {
        sharedDefaultsWriters.removeAll()
        UserDefaults.standard.removeObject(forKey: defaultsKey)
    }
    
    // Need to restore this during testing
    var registeredDefaults: [String: Any] = [:]
    
    @MainActor
    override func setUp() {
        resetState()
    }
    @MainActor
    override func tearDown() {
        resetState()
    }
    
    func saveRegisteredDefaults() {
        registeredDefaults = UserDefaults.standard.volatileDomain(forName: UserDefaults.registrationDomain)
    }

    func restoreRegisteredDefaults() {
        UserDefaults.standard.setVolatileDomain(registeredDefaults, forName: UserDefaults.registrationDomain)
    }

    
    func testWritingDefaults() {
        let s = MockView<DictionaryRecord>()
        s.value.bar = "123"
        
        let s2 = MockView<DictionaryRecord>()
        XCTAssertEqual(s2.value.bar, "123")
        
    }

    func testDefaultsStartNil() {
        let s = MockView<DictionaryRecord>()
        
        // Until you write, defaults should be unchanged
        XCTAssertNil(UserDefaults.standard.object(forKey: defaultsKey))
        
        s.value.bar = "ABC"

        XCTAssertNotNil(UserDefaults.standard.object(forKey: defaultsKey))
    }
    
    func testRegisteredDefaultsAreReflected() {
        saveRegisteredDefaults()
        // This test must use an alternate defaults key, otherwise the other tests don't work
        UserDefaults.standard.register(defaults: [defaultsKey: [
            "foo": 123,
            "bar": "111",
            "bash": "ABCABC"
        ]])
        let s = MockView<DictionaryRecord>()
        XCTAssertEqual(s.value, DictionaryRecord(foo: 123, bar: "111", bash: "ABCABC"))
        
        restoreRegisteredDefaults()
        resetState()
        
        let s2 = MockView<DictionaryRecord>()
        XCTAssertNotEqual(s2.value, DictionaryRecord(foo: 123, bar: "111", bash: "ABCABC"))

    }

    
    func testDefaultsAreDictionary() {
        // Until you write, defaults should be unchanged
        XCTAssertNil(UserDefaults.standard.object(forKey: defaultsKey))

        let s = MockView<DictionaryRecord>()
        s.value.bar = "ABC"
        s.value.bash = "SNT"

        let expected: [String: Any] = [
            "foo": 0.0,
            "bar": "ABC",
            "bash": "SNT"
        ]
        
        let actual = UserDefaults.standard.object(forKey: defaultsKey)
        XCTAssertEqual(actual! as! NSDictionary, expected as NSDictionary)
    }


}


final class DefaultsWriterTests: XCTestCase {

    func testDefaultsMatchExpected() {

    }
}
