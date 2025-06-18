import Foundation

/// A reusable field validator that applies rules to a specific value.
///
/// `FieldValidator` provides a fluent interface for validating individual fields:
///
/// ```swift
/// var validator = FieldValidator(fieldName: "email", value: email)
/// validator.required()
/// validator.notEmpty()
/// validator.matchesEmail()
/// let errors = validator.getErrors()
/// ```
public struct FieldValidator<T> {
    /// The name of the field being validated.
    public let fieldName: String
    
    /// The value to validate.
    public let value: T?
    
    /// Validation errors found.
    private var errors: [ValidationError] = []
    
    /// Creates a new field validator.
    /// - Parameters:
    ///   - fieldName: The name of the field being validated.
    ///   - value: The value to validate.
    public init(fieldName: String, value: T?) {
        self.fieldName = fieldName
        self.value = value
    }
    
    /// Validates that the field is not nil.
    public mutating func required() {
        if value == nil {
            errors.append(ValidationError(field: fieldName, rule: .required))
        }
    }
    
    /// Validates string is not empty or whitespace-only.
    public mutating func notEmpty() where T == String {
        if let stringValue = value {
            let trimmed = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty {
                errors.append(ValidationError(field: fieldName, rule: .empty))
            }
        }
    }
    
    /// Validates string length is within maximum.
    /// - Parameter max: The maximum allowed length.
    public mutating func maxLength(_ max: Int) where T == String {
        if let stringValue = value {
            let trimmed = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.count > max {
                errors.append(ValidationError(field: fieldName, rule: .tooLong(max: max)))
            }
        }
    }
    
    /// Validates string length meets minimum.
    /// - Parameter min: The minimum required length.
    public mutating func minLength(_ min: Int) where T == String {
        if let stringValue = value {
            let trimmed = stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.count < min {
                errors.append(ValidationError(field: fieldName, rule: .tooShort(min: min)))
            }
        }
    }
    
    /// Validates numeric value is within range.
    /// - Parameters:
    ///   - min: The minimum allowed value.
    ///   - max: The maximum allowed value.
    public mutating func range(min: Int, max: Int) where T == Int {
        if let intValue = value {
            if intValue < min || intValue > max {
                errors.append(ValidationError(field: fieldName, rule: .outOfRange(min: min, max: max)))
            }
        }
    }
    
    /// Validates numeric value is within range.
    /// - Parameters:
    ///   - min: The minimum allowed value.
    ///   - max: The maximum allowed value.
    public mutating func range(min: Double, max: Double) where T == Double {
        if let doubleValue = value {
            if doubleValue < min || doubleValue > max {
                errors.append(ValidationError(field: fieldName, rule: .outOfRange(min: Int(min), max: Int(max))))
            }
        }
    }
    
    /// Validates date is not in the future.
    public mutating func notFuture() where T == Date {
        if let dateValue = value {
            if dateValue > Date() {
                errors.append(ValidationError(field: fieldName, rule: .invalidFormat(reason: "cannot be in the future")))
            }
        }
    }
    
    /// Validates date is not in the past.
    public mutating func notPast() where T == Date {
        if let dateValue = value {
            if dateValue < Date() {
                errors.append(ValidationError(field: fieldName, rule: .invalidFormat(reason: "cannot be in the past")))
            }
        }
    }
    
    /// Validates string matches email format.
    public mutating func matchesEmail() where T == String {
        if let stringValue = value {
            let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
            let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
            if !predicate.evaluate(with: stringValue) {
                errors.append(ValidationError(field: fieldName, rule: .invalidEmail))
            }
        }
    }
    
    /// Validates string matches URL format.
    public mutating func matchesURL() where T == String {
        if let stringValue = value {
            // Check if it's a valid URL with proper scheme
            guard let url = URL(string: stringValue),
                  let scheme = url.scheme,
                  !scheme.isEmpty,
                  url.host != nil else {
                errors.append(ValidationError(field: fieldName, rule: .invalidURL))
                return
            }
        }
    }
    
    /// Validates string matches phone number format.
    /// - Parameter allowInternational: Whether to allow international phone numbers.
    public mutating func matchesPhoneNumber(allowInternational: Bool = true) where T == String {
        if let stringValue = value {
            // Remove common formatting characters for validation
            let cleaned = stringValue.replacingOccurrences(of: "[\\s\\-\\(\\)\\.]", with: "", options: .regularExpression)
            
            let phoneRegex = allowInternational
                ? #"^\+?[0-9]{7,15}$"# // International: optional + followed by 7-15 digits
                : #"^[0-9]{10}$"# // US: exactly 10 digits
            
            let predicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
            if !predicate.evaluate(with: cleaned) {
                errors.append(ValidationError(field: fieldName, rule: .invalidPhoneNumber))
            }
        }
    }
    
    /// Validates value matches another value.
    /// - Parameters:
    ///   - otherValue: The value to match against.
    ///   - otherFieldName: The name of the other field for error messages.
    public mutating func matches(_ otherValue: T?, fieldName otherFieldName: String) where T: Equatable {
        if let value = value, let otherValue = otherValue {
            if value != otherValue {
                errors.append(ValidationError(field: fieldName, rule: .notMatching(otherField: otherFieldName)))
            }
        }
    }
    
    /// Adds a custom validation with a predicate.
    /// - Parameters:
    ///   - predicate: A closure that returns true if the value is valid.
    ///   - error: The validation rule to use if validation fails.
    public mutating func custom(_ predicate: (T?) -> Bool, error: ValidationRule) {
        if !predicate(value) {
            errors.append(ValidationError(field: fieldName, rule: error))
        }
    }
    
    /// Returns all validation errors.
    /// - Returns: An array of validation errors.
    public func getErrors() -> [ValidationError] {
        errors
    }
}

/// Helper to create validators more concisely.
///
/// `Validator` provides a fluent interface for validating multiple fields:
///
/// ```swift
/// var validator = Validator()
///
/// validator.validate(field: "name", value: name) { validator in
///     validator.required()
///     validator.notEmpty()
///     validator.maxLength(50)
/// }
///
/// validator.validate(field: "age", value: age) { validator in
///     validator.required()
///     validator.range(min: 0, max: 150)
/// }
///
/// let errors = validator.errors()
/// ```
public struct Validator {
    private var validationErrors: [ValidationError] = []
    
    /// Creates a new validator.
    public init() {}
    
    /// Validates a field with the given name and value.
    /// - Parameters:
    ///   - field: The name of the field being validated.
    ///   - value: The value to validate.
    ///   - validator: A closure that performs validation on the field.
    public mutating func validate<T>(field: String, value: T?, _ validator: (inout FieldValidator<T>) -> Void) {
        var fieldValidator = FieldValidator(fieldName: field, value: value)
        validator(&fieldValidator)
        validationErrors.append(contentsOf: fieldValidator.getErrors())
    }
    
    /// Returns all accumulated errors.
    /// - Returns: An array of all validation errors.
    public func errors() -> [ValidationError] {
        validationErrors
    }
    
    /// Checks if validation passed (no errors).
    /// - Returns: true if there are no validation errors.
    public func isValid() -> Bool {
        validationErrors.isEmpty
    }
}