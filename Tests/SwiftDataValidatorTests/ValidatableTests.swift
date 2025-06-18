import Testing
@testable import SwiftDataValidator
import Foundation

// Mock model for testing
final class MockUser: Validatable {
    var name: String?
    var email: String?
    var age: Int?
    var password: String?
    var confirmPassword: String?

    init(
        name: String? = nil,
        email: String? = nil,
        age: Int? = nil,
        password: String? = nil,
        confirmPassword: String? = nil
    ) {
        self.name = name
        self.email = email
        self.age = age
        self.password = password
        self.confirmPassword = confirmPassword
    }

    func validate() -> [ValidationError] {
        var validator = Validator()

        validator.validate(field: "name", value: name) { validator in
            validator.required()
            validator.notEmpty()
            validator.maxLength(50)
        }

        validator.validate(field: "email", value: email) { validator in
            validator.required()
            validator.matchesEmail()
        }

        validator.validate(field: "age", value: age) { validator in
            validator.required()
            validator.range(min: 18, max: 120)
        }

        validator.validate(field: "password", value: password) { validator in
            validator.required()
            validator.minLength(8)
            validator.maxLength(128)
        }

        validator.validate(field: "confirmPassword", value: confirmPassword) { validator in
            validator.matches(password, fieldName: "password")
        }

        return validator.errors()
    }
}

@Suite("Validatable Protocol Tests")
struct ValidatableTests {

    @Test("Valid model should have no errors")
    func testValidModel() {
        let user = MockUser(
            name: "John Doe",
            email: "john@example.com",
            age: 25,
            password: "securepass123",
            confirmPassword: "securepass123"
        )

        let errors = user.validate()
        #expect(errors.isEmpty)
    }

    @Test("Missing required fields should produce errors")
    func testMissingRequiredFields() {
        let user = MockUser()
        let errors = user.validate()

        #expect(errors.count == 4) // name, email, age, password are required

        let errorFields = errors.map { $0.field }
        #expect(errorFields.contains("name"))
        #expect(errorFields.contains("email"))
        #expect(errorFields.contains("age"))
        #expect(errorFields.contains("password"))

        for error in errors {
            #expect(error.rule == .required)
        }
    }

    @Test("Empty name should produce error")
    func testEmptyName() {
        let user = MockUser(
            name: "   ",
            email: "john@example.com",
            age: 25,
            password: "securepass123"
        )

        let errors = user.validate()
        #expect(errors.count == 1)
        #expect(errors[0].field == "name")
        #expect(errors[0].rule == .empty)
    }

    @Test("Invalid email should produce error")
    func testInvalidEmail() {
        let user = MockUser(
            name: "John Doe",
            email: "invalid-email",
            age: 25,
            password: "securepass123"
        )

        let errors = user.validate()
        #expect(errors.count == 1)
        #expect(errors[0].field == "email")
        #expect(errors[0].rule == .invalidEmail)
    }

    @Test("Age out of range should produce error")
    func testAgeOutOfRange() {
        let user = MockUser(
            name: "John Doe",
            email: "john@example.com",
            age: 150,
            password: "securepass123"
        )

        let errors = user.validate()
        #expect(errors.count == 1)
        #expect(errors[0].field == "age")
        #expect(errors[0].rule == .outOfRange(min: 18, max: 120))
    }

    @Test("Password too short should produce error")
    func testPasswordTooShort() {
        let user = MockUser(
            name: "John Doe",
            email: "john@example.com",
            age: 25,
            password: "short"
        )

        let errors = user.validate()
        #expect(errors.count == 1)
        #expect(errors[0].field == "password")
        #expect(errors[0].rule == .tooShort(min: 8))
    }

    @Test("Passwords not matching should produce error")
    func testPasswordsNotMatching() {
        let user = MockUser(
            name: "John Doe",
            email: "john@example.com",
            age: 25,
            password: "securepass123",
            confirmPassword: "differentpass123"
        )

        let errors = user.validate()
        #expect(errors.count == 1)
        #expect(errors[0].field == "confirmPassword")
        #expect(errors[0].rule == .notMatching(otherField: "password"))
    }

    @Test("Multiple validation errors")
    func testMultipleErrors() {
        let user = MockUser(
            name: String(repeating: "a", count: 51), // Too long
            email: "not-an-email", // Invalid format
            age: 10, // Too young
            password: "123" // Too short
        )

        let errors = user.validate()
        #expect(errors.count == 4)

        let errorsByField = Dictionary(grouping: errors, by: { $0.field })
        #expect(errorsByField["name"]?.first?.rule == .tooLong(max: 50))
        #expect(errorsByField["email"]?.first?.rule == .invalidEmail)
        #expect(errorsByField["age"]?.first?.rule == .outOfRange(min: 18, max: 120))
        #expect(errorsByField["password"]?.first?.rule == .tooShort(min: 8))
    }
}
