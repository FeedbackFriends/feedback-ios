public struct PinCodeValidator {
    
    public static let pinMax = 4
    
    public static func isValidPinCode(_ pinCode: String) -> Bool {
        return pinCode.count == pinMax && pinCode.allSatisfy { $0.isNumber }
    }
}
