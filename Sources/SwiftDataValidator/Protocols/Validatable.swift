import Foundation

/// Protocol for SwiftData models that support validation.
///
/// Conform your SwiftData models to this protocol to enable validation:
///
/// ```swift
/// @Model
/// final class User: Validatable {
///     var name: String = ""
///     var email: String = ""
///
///     func validate() -> [ValidationError] {
///         var validator = Validator()
///
///         validator.validate(field: "name", value: name) { validator in
///             validator.required()
///             validator.notEmpty()
///             validator.maxLength(50)
///         }
///
///         validator.validate(field: "email", value: email) { validator in
///             validator.required()
///             validator.matchesEmail()
///         }
///
///         return validator.errors()
///     }
/// }
/// ```
public protocol Validatable {
    /// Validates the model and returns any validation errors.
    /// - Returns: Array of validation errors, empty if model is valid.
    func validate() -> [ValidationError]
}
