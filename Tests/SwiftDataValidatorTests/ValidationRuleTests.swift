import Testing
@testable import SwiftDataValidator
import Foundation

@Suite("ValidationRule and ValidationError Tests")
struct ValidationRuleTests {
    
    @Suite("ValidationError Localization")
    struct ErrorLocalization {
        
        @Test("Error descriptions are properly formatted")
        func testErrorDescriptions() {
            let testCases: [(ValidationError, String)] = [
                (ValidationError(field: "username", rule: .required), "username is required"),
                (ValidationError(field: "name", rule: .empty), "name cannot be empty"),
                (ValidationError(field: "bio", rule: .tooLong(max: 100)), "bio is too long (maximum 100 characters)"),
                (ValidationError(field: "password", rule: .tooShort(min: 8)), "password is too short (minimum 8 characters)"),
                (ValidationError(field: "age", rule: .outOfRange(min: 18, max: 65)), "age must be between 18 and 65"),
                (ValidationError(field: "date", rule: .invalidFormat(reason: "must be in ISO format")), "date has invalid format: must be in ISO format"),
                (ValidationError(field: "status", rule: .businessRule(reason: "Cannot change from completed")), "Cannot change from completed"),
                (ValidationError(field: "field", rule: .custom(message: "Custom error message")), "Custom error message"),
                (ValidationError(field: "email", rule: .invalidEmail), "email must be a valid email address"),
                (ValidationError(field: "website", rule: .invalidURL), "website must be a valid URL"),
                (ValidationError(field: "phone", rule: .invalidPhoneNumber), "phone must be a valid phone number"),
                (ValidationError(field: "username", rule: .notUnique), "username must be unique"),
                (ValidationError(field: "confirmEmail", rule: .notMatching(otherField: "email")), "confirmEmail must match email")
            ]
            
            for (error, expectedDescription) in testCases {
                #expect(error.errorDescription == expectedDescription)
            }
        }
        
        @Test("Recovery suggestions are helpful")
        func testRecoverySuggestions() {
            let testCases: [(ValidationError, String?)] = [
                (ValidationError(field: "username", rule: .required), "Please provide a value for username"),
                (ValidationError(field: "name", rule: .empty), "Enter a non-empty value for name"),
                (ValidationError(field: "bio", rule: .tooLong(max: 100)), "Shorten bio to 100 characters or less"),
                (ValidationError(field: "password", rule: .tooShort(min: 8)), "Lengthen password to at least 8 characters"),
                (ValidationError(field: "age", rule: .outOfRange(min: 18, max: 65)), "Choose a value between 18 and 65"),
                (ValidationError(field: "date", rule: .invalidFormat(reason: "must be ISO")), "Check the format: must be ISO"),
                (ValidationError(field: "status", rule: .businessRule(reason: "reason")), nil),
                (ValidationError(field: "field", rule: .custom(message: "message")), nil),
                (ValidationError(field: "email", rule: .invalidEmail), "Enter a valid email address (e.g., user@example.com)"),
                (ValidationError(field: "website", rule: .invalidURL), "Enter a valid URL (e.g., https://example.com)"),
                (ValidationError(field: "phone", rule: .invalidPhoneNumber), "Enter a valid phone number"),
                (ValidationError(field: "username", rule: .notUnique), "This username is already in use"),
                (ValidationError(field: "confirmEmail", rule: .notMatching(otherField: "email")), "Ensure confirmEmail matches email")
            ]
            
            for (error, expectedSuggestion) in testCases {
                #expect(error.recoverySuggestion == expectedSuggestion)
            }
        }
    }
    
    @Suite("ValidationError Equality")
    struct ErrorEquality {
        
        @Test("Errors with same field and rule are equal")
        func testErrorEquality() {
            let error1 = ValidationError(field: "name", rule: .required)
            let error2 = ValidationError(field: "name", rule: .required)
            #expect(error1 == error2)
            
            let error3 = ValidationError(field: "age", rule: .outOfRange(min: 18, max: 65))
            let error4 = ValidationError(field: "age", rule: .outOfRange(min: 18, max: 65))
            #expect(error3 == error4)
        }
        
        @Test("Errors with different fields are not equal")
        func testErrorInequalityDifferentField() {
            let error1 = ValidationError(field: "name", rule: .required)
            let error2 = ValidationError(field: "email", rule: .required)
            #expect(error1 != error2)
        }
        
        @Test("Errors with different rules are not equal")
        func testErrorInequalityDifferentRule() {
            let error1 = ValidationError(field: "name", rule: .required)
            let error2 = ValidationError(field: "name", rule: .empty)
            #expect(error1 != error2)
            
            let error3 = ValidationError(field: "age", rule: .outOfRange(min: 18, max: 65))
            let error4 = ValidationError(field: "age", rule: .outOfRange(min: 21, max: 65))
            #expect(error3 != error4)
        }
    }
    
    @Suite("Validator Helper")
    struct ValidatorHelper {
        
        @Test("Validator accumulates errors from multiple fields")
        func testValidatorAccumulation() {
            var validator = Validator()
            
            validator.validate(field: "name", value: nil as String?) { validator in
                validator.required()
            }
            
            validator.validate(field: "email", value: "invalid") { validator in
                validator.matchesEmail()
            }
            
            validator.validate(field: "age", value: 200) { validator in
                validator.range(min: 0, max: 150)
            }
            
            let errors = validator.errors()
            #expect(errors.count == 3)
            #expect(validator.isValid() == false)
            
            let errorFields = Set(errors.map { $0.field })
            #expect(errorFields == ["name", "email", "age"])
        }
        
        @Test("Valid data produces no errors")
        func testValidatorNoErrors() {
            var validator = Validator()
            
            validator.validate(field: "name", value: "John Doe") { validator in
                validator.required()
                validator.notEmpty()
                validator.maxLength(50)
            }
            
            validator.validate(field: "email", value: "john@example.com") { validator in
                validator.required()
                validator.matchesEmail()
            }
            
            validator.validate(field: "age", value: 30) { validator in
                validator.required()
                validator.range(min: 0, max: 150)
            }
            
            #expect(validator.errors().isEmpty)
            #expect(validator.isValid())
        }
        
        @Test("Multiple errors on same field")
        func testMultipleErrorsSameField() {
            var validator = Validator()
            
            validator.validate(field: "password", value: "") { validator in
                validator.required() // This won't trigger since value is not nil
                validator.notEmpty() // This will trigger
                validator.minLength(8) // This will also trigger
            }
            
            let errors = validator.errors()
            #expect(errors.count == 2)
            #expect(errors.allSatisfy { $0.field == "password" })
        }
    }
    
    @Suite("ValidationConstants")
    struct Constants {
        
        @Test("Default constants have reasonable values")
        func testDefaultConstants() {
            #expect(ValidationConstants.defaultMaxNameLength == 50)
            #expect(ValidationConstants.defaultMaxDescriptionLength == 500)
            #expect(ValidationConstants.defaultMinPasswordLength == 8)
            #expect(ValidationConstants.defaultMaxPasswordLength == 128)
        }
    }
}