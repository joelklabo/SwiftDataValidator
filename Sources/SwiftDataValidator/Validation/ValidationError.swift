import Foundation

/// Represents a validation error for a model field.
///
/// `ValidationError` provides localized error descriptions and recovery suggestions
/// for common validation failures.
public struct ValidationError: LocalizedError, Equatable, Sendable {
    /// The field that failed validation.
    public let field: String
    
    /// The validation rule that was violated.
    public let rule: ValidationRule
    
    /// Creates a new validation error.
    /// - Parameters:
    ///   - field: The name of the field that failed validation.
    ///   - rule: The validation rule that was violated.
    public init(field: String, rule: ValidationRule) {
        self.field = field
        self.rule = rule
    }
    
    /// A localized description of the validation error.
    public var errorDescription: String? {
        switch rule {
        case .required:
            return "\(field) is required"
        case .empty:
            return "\(field) cannot be empty"
        case .tooLong(let max):
            return "\(field) is too long (maximum \(max) characters)"
        case .tooShort(let min):
            return "\(field) is too short (minimum \(min) characters)"
        case .outOfRange(let min, let max):
            return "\(field) must be between \(min) and \(max)"
        case .invalidFormat(let reason):
            return "\(field) has invalid format: \(reason)"
        case .businessRule(let reason):
            return reason
        case .custom(let message):
            return message
        case .invalidEmail:
            return "\(field) must be a valid email address"
        case .invalidURL:
            return "\(field) must be a valid URL"
        case .invalidPhoneNumber:
            return "\(field) must be a valid phone number"
        case .notUnique:
            return "\(field) must be unique"
        case .notMatching(let otherField):
            return "\(field) must match \(otherField)"
        }
    }
    
    /// A localized recovery suggestion for the validation error.
    public var recoverySuggestion: String? {
        switch rule {
        case .required:
            return "Please provide a value for \(field)"
        case .empty:
            return "Enter a non-empty value for \(field)"
        case .tooLong(let max):
            return "Shorten \(field) to \(max) characters or less"
        case .tooShort(let min):
            return "Lengthen \(field) to at least \(min) characters"
        case .outOfRange(let min, let max):
            return "Choose a value between \(min) and \(max)"
        case .invalidFormat(let reason):
            return "Check the format: \(reason)"
        case .businessRule:
            return nil
        case .custom:
            return nil
        case .invalidEmail:
            return "Enter a valid email address (e.g., user@example.com)"
        case .invalidURL:
            return "Enter a valid URL (e.g., https://example.com)"
        case .invalidPhoneNumber:
            return "Enter a valid phone number"
        case .notUnique:
            return "This \(field) is already in use"
        case .notMatching(let otherField):
            return "Ensure \(field) matches \(otherField)"
        }
    }
    
    public static func == (lhs: ValidationError, rhs: ValidationError) -> Bool {
        lhs.field == rhs.field && lhs.rule == rhs.rule
    }
}