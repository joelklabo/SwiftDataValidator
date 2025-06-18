import Foundation

/// Enumeration of validation rules that can be applied to model fields.
public enum ValidationRule: Equatable, Sendable {
    /// Field is required (not nil).
    case required

    /// String field cannot be empty or whitespace-only.
    case empty

    /// String field exceeds maximum length.
    case tooLong(max: Int)

    /// String field is below minimum length.
    case tooShort(min: Int)

    /// Numeric field is outside valid range.
    case outOfRange(min: Int, max: Int)

    /// Field has invalid format.
    case invalidFormat(reason: String)

    /// Business rule violation.
    case businessRule(reason: String)

    /// Custom validation error.
    case custom(message: String)

    /// Email validation failed.
    case invalidEmail

    /// URL validation failed.
    case invalidURL

    /// Phone number validation failed.
    case invalidPhoneNumber

    /// Uniqueness constraint violated.
    case notUnique

    /// Field doesn't match another field.
    case notMatching(otherField: String)
}

/// Common validation constants.
public enum ValidationConstants {
    /// Default maximum length for names.
    public static let defaultMaxNameLength = 50

    /// Default maximum length for descriptions.
    public static let defaultMaxDescriptionLength = 500

    /// Default minimum password length.
    public static let defaultMinPasswordLength = 8

    /// Default maximum password length.
    public static let defaultMaxPasswordLength = 128
}
