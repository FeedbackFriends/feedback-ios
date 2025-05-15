import Testing
@testable import Utility

final class StringExtensionsTests {
    
    @Test
    func testNilIfEmpty_withEmptyString_returnsNil() {
        let emptyString = ""
        #expect(emptyString.nilIfEmpty == nil)
    }
    
    @Test
    func testNilIfEmpty_withNonEmptyString_returnsString() {
        let nonEmptyString = "Hello"
        #expect(nonEmptyString.nilIfEmpty == "Hello")
    }
    
    @Test
    func testLowercasingFirst_withEmptyString_returnsEmptyString() {
        let emptyString = ""
        #expect(emptyString.lowercasingFirst() == "")
    }
    
    @Test
    func testLowercasingFirst_withNonEmptyString_returnsLowercaseFirst() {
        let string = "Hello"
        #expect(string.lowercasingFirst() == "hello")
    }
    
    @Test
    func testUppercasingFirst_withEmptyString_returnsEmptyString() {
        let emptyString = ""
        #expect(emptyString.uppercasingFirst() == "")
    }
    
    @Test
    func testUppercasingFirst_withNonEmptyString_returnsUppercaseFirst() {
        let string = "helloHello"
        #expect(string.uppercasingFirst() == "HelloHello")
    }
}
