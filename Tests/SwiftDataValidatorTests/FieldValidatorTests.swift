import Testing
@testable import SwiftDataValidator
import Foundation

@Suite("FieldValidator Tests")
struct FieldValidatorTests {
    
    @Suite("String Validation")
    struct StringValidation {
        
        @Test("Required validation")
        func testRequired() {
            var validator = FieldValidator(fieldName: "name", value: nil as String?)
            validator.required()
            let errors = validator.getErrors()
            
            #expect(errors.count == 1)
            #expect(errors[0].rule == .required)
            
            validator = FieldValidator(fieldName: "name", value: "John")
            validator.required()
            #expect(validator.getErrors().isEmpty)
        }
        
        @Test("Not empty validation")
        func testNotEmpty() {
            var validator = FieldValidator(fieldName: "name", value: "")
            validator.notEmpty()
            #expect(validator.getErrors().count == 1)
            
            validator = FieldValidator(fieldName: "name", value: "   ")
            validator.notEmpty()
            #expect(validator.getErrors().count == 1)
            
            validator = FieldValidator(fieldName: "name", value: "John")
            validator.notEmpty()
            #expect(validator.getErrors().isEmpty)
        }
        
        @Test("Max length validation")
        func testMaxLength() {
            var validator = FieldValidator(fieldName: "name", value: "John")
            validator.maxLength(10)
            #expect(validator.getErrors().isEmpty)
            
            validator = FieldValidator(fieldName: "name", value: String(repeating: "a", count: 11))
            validator.maxLength(10)
            #expect(validator.getErrors().count == 1)
            #expect(validator.getErrors()[0].rule == .tooLong(max: 10))
        }
        
        @Test("Min length validation")
        func testMinLength() {
            var validator = FieldValidator(fieldName: "name", value: "Jo")
            validator.minLength(3)
            #expect(validator.getErrors().count == 1)
            #expect(validator.getErrors()[0].rule == .tooShort(min: 3))
            
            validator = FieldValidator(fieldName: "name", value: "John")
            validator.minLength(3)
            #expect(validator.getErrors().isEmpty)
        }
        
        @Test("Email validation")
        func testEmailValidation() {
            let validEmails = [
                "test@example.com",
                "user.name@example.com",
                "user+tag@example.co.uk",
                "test123@subdomain.example.com"
            ]
            
            for email in validEmails {
                var validator = FieldValidator(fieldName: "email", value: email)
                validator.matchesEmail()
                #expect(validator.getErrors().isEmpty, "'\(email)' should be valid")
            }
            
            let invalidEmails = [
                "notanemail",
                "@example.com",
                "test@",
                "test@.com",
                "test@example",
                "test @example.com"
            ]
            
            for email in invalidEmails {
                var validator = FieldValidator(fieldName: "email", value: email)
                validator.matchesEmail()
                #expect(validator.getErrors().count == 1, "'\(email)' should be invalid")
            }
        }
        
        @Test("URL validation")
        func testURLValidation() {
            let validURLs = [
                "https://example.com",
                "http://subdomain.example.com",
                "https://example.com/path/to/resource",
                "https://example.com:8080"
            ]
            
            for url in validURLs {
                var validator = FieldValidator(fieldName: "url", value: url)
                validator.matchesURL()
                #expect(validator.getErrors().isEmpty, "'\(url)' should be valid")
            }
            
            let invalidURLs = [
                "not a url",
                "://example.com",
                "example.com" // Missing scheme
            ]
            
            for url in invalidURLs {
                var validator = FieldValidator(fieldName: "url", value: url)
                validator.matchesURL()
                #expect(validator.getErrors().count == 1, "'\(url)' should be invalid")
            }
        }
        
        @Test("Phone number validation")
        func testPhoneNumberValidation() {
            let validPhones = [
                "123-456-7890",
                "(123) 456-7890",
                "123.456.7890",
                "+1 123 456 7890",
                "+44 20 7946 0958"
            ]
            
            for phone in validPhones {
                var validator = FieldValidator(fieldName: "phone", value: phone)
                validator.matchesPhoneNumber(allowInternational: true)
                #expect(validator.getErrors().isEmpty, "'\(phone)' should be valid")
            }
            
            let invalidPhones = [
                "123",
                "abcd-efg-hijk",
                "123-456-7890123456" // Too long (16 digits)
            ]
            
            for phone in invalidPhones {
                var validator = FieldValidator(fieldName: "phone", value: phone)
                validator.matchesPhoneNumber()
                #expect(validator.getErrors().count == 1, "'\(phone)' should be invalid")
            }
        }
    }
    
    @Suite("Numeric Validation")
    struct NumericValidation {
        
        @Test("Int range validation")
        func testIntRange() {
            var validator = FieldValidator(fieldName: "age", value: 25)
            validator.range(min: 18, max: 65)
            #expect(validator.getErrors().isEmpty)
            
            validator = FieldValidator(fieldName: "age", value: 10)
            validator.range(min: 18, max: 65)
            #expect(validator.getErrors().count == 1)
            #expect(validator.getErrors()[0].rule == .outOfRange(min: 18, max: 65))
            
            validator = FieldValidator(fieldName: "age", value: 70)
            validator.range(min: 18, max: 65)
            #expect(validator.getErrors().count == 1)
        }
        
        @Test("Double range validation")
        func testDoubleRange() {
            var validator = FieldValidator(fieldName: "price", value: 19.99)
            validator.range(min: 0.0, max: 100.0)
            #expect(validator.getErrors().isEmpty)
            
            validator = FieldValidator(fieldName: "price", value: -5.0)
            validator.range(min: 0.0, max: 100.0)
            #expect(validator.getErrors().count == 1)
            
            validator = FieldValidator(fieldName: "price", value: 150.0)
            validator.range(min: 0.0, max: 100.0)
            #expect(validator.getErrors().count == 1)
        }
    }
    
    @Suite("Date Validation")
    struct DateValidation {
        
        @Test("Not future validation")
        func testNotFuture() {
            let futureDate = Date().addingTimeInterval(86400) // Tomorrow
            var validator = FieldValidator(fieldName: "date", value: futureDate)
            validator.notFuture()
            #expect(validator.getErrors().count == 1)
            
            let pastDate = Date().addingTimeInterval(-86400) // Yesterday
            validator = FieldValidator(fieldName: "date", value: pastDate)
            validator.notFuture()
            #expect(validator.getErrors().isEmpty)
        }
        
        @Test("Not past validation")
        func testNotPast() {
            let pastDate = Date().addingTimeInterval(-86400) // Yesterday
            var validator = FieldValidator(fieldName: "date", value: pastDate)
            validator.notPast()
            #expect(validator.getErrors().count == 1)
            
            let futureDate = Date().addingTimeInterval(86400) // Tomorrow
            validator = FieldValidator(fieldName: "date", value: futureDate)
            validator.notPast()
            #expect(validator.getErrors().isEmpty)
        }
    }
    
    @Suite("Custom Validation")
    struct CustomValidation {
        
        @Test("Custom predicate validation")
        func testCustomPredicate() {
            var validator = FieldValidator(fieldName: "username", value: "admin")
            validator.custom({ value in
                value != "admin" // Username cannot be "admin"
            }, error: .businessRule(reason: "Username 'admin' is reserved"))
            
            #expect(validator.getErrors().count == 1)
            #expect(validator.getErrors()[0].rule == .businessRule(reason: "Username 'admin' is reserved"))
            
            validator = FieldValidator(fieldName: "username", value: "john")
            validator.custom({ value in
                value != "admin"
            }, error: .businessRule(reason: "Username 'admin' is reserved"))
            
            #expect(validator.getErrors().isEmpty)
        }
    }
    
    @Suite("Field Matching")
    struct FieldMatching {
        
        @Test("Fields match validation")
        func testFieldsMatch() {
            var validator = FieldValidator(fieldName: "confirmPassword", value: "password123")
            validator.matches("password123", fieldName: "password")
            #expect(validator.getErrors().isEmpty)
            
            validator = FieldValidator(fieldName: "confirmPassword", value: "password123")
            validator.matches("differentPassword", fieldName: "password")
            #expect(validator.getErrors().count == 1)
            #expect(validator.getErrors()[0].rule == .notMatching(otherField: "password"))
        }
    }
}