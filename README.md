# SwiftDataValidator

[![CI](https://github.com/joelklabo/SwiftDataValidator/actions/workflows/ci.yml/badge.svg?branch=main&event=push)](https://github.com/joelklabo/SwiftDataValidator/actions/workflows/ci.yml)
[![Swift 6.0](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
![Platforms](https://img.shields.io/badge/Platforms-iOS%2018%2B%20%7C%20macOS%2015%2B%20%7C%20tvOS%2018%2B%20%7C%20watchOS%2011%2B%20%7C%20visionOS%202%2B-blue)

A comprehensive validation framework for SwiftData models with a clean, declarative API.

## Features

- 🎯 **Type-safe validation** with Swift generics
- 📝 **Declarative API** for defining validation rules
- 🌍 **Localized error messages** with recovery suggestions
- 🔧 **Built-in validators** for common use cases
- 🎨 **Custom validation rules** for business logic
- 📦 **Zero dependencies** - pure Swift implementation
- 🚀 **Swift 6 ready** with full concurrency support
- 📱 **Multi-platform** - iOS, macOS, tvOS, watchOS, visionOS

## Requirements

- Swift 6.0+
- iOS 18.0+ / macOS 15.0+ / tvOS 18.0+ / watchOS 11.0+ / visionOS 2.0+

## Installation

### Swift Package Manager

Add SwiftDataValidator to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/joelklabo/SwiftDataValidator", from: "1.0.0")
]
```

Or add it through Xcode:
1. File → Add Package Dependencies...
2. Enter: `https://github.com/joelklabo/SwiftDataValidator`
3. Click Add Package

## Quick Start

### 1. Make your SwiftData model conform to `Validatable`:

```swift
import SwiftData
import SwiftDataValidator

@Model
final class User: Validatable {
    var name: String = ""
    var email: String = ""
    var age: Int = 0
    
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
        
        return validator.errors()
    }
}
```

### 2. Validate before saving:

```swift
let user = User()
user.name = "John Doe"
user.email = "john@example.com"
user.age = 25

let errors = user.validate()
if errors.isEmpty {
    context.insert(user)
    try context.save()
} else {
    // Handle validation errors
    for error in errors {
        print("\(error.field): \(error.localizedDescription)")
        if let suggestion = error.recoverySuggestion {
            print("  → \(suggestion)")
        }
    }
}
```

## Available Validators

### String Validators

```swift
validator.validate(field: "username", value: username) { validator in
    validator.required()           // Not nil
    validator.notEmpty()          // Not empty or whitespace
    validator.minLength(3)        // Minimum length
    validator.maxLength(20)       // Maximum length
    validator.matchesEmail()      // Valid email format
    validator.matchesURL()        // Valid URL format
    validator.matchesPhoneNumber() // Valid phone number
}
```

### Numeric Validators

```swift
validator.validate(field: "age", value: age) { validator in
    validator.required()
    validator.range(min: 0, max: 150)  // Within range
}
```

### Date Validators

```swift
validator.validate(field: "birthDate", value: birthDate) { validator in
    validator.required()
    validator.notFuture()  // Not in the future
    validator.notPast()    // Not in the past
}
```

### Field Matching

```swift
validator.validate(field: "confirmPassword", value: confirmPassword) { validator in
    validator.required()
    validator.matches(password, fieldName: "password")
}
```

### Custom Validators

```swift
validator.validate(field: "username", value: username) { validator in
    validator.custom({ value in
        // Return true if valid
        return value != "admin"
    }, error: .businessRule(reason: "Username 'admin' is reserved"))
}
```

## Advanced Usage

### Custom Validation Rules

You can create custom validation rules using the `ValidationRule` enum:

```swift
extension ValidationRule {
    static func mustContainSpecialCharacter() -> ValidationRule {
        .custom(message: "Password must contain at least one special character")
    }
}

// Usage
validator.validate(field: "password", value: password) { validator in
    validator.custom({ password in
        guard let password else { return false }
        let specialCharacters = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")
        return password.rangeOfCharacter(from: specialCharacters) != nil
    }, error: .mustContainSpecialCharacter())
}
```

### Validation in SwiftUI

Create a view model that handles validation:

```swift
@Observable
final class UserFormViewModel {
    var name = ""
    var email = ""
    var errors: [ValidationError] = []
    
    func validate() {
        let user = User()
        user.name = name
        user.email = email
        errors = user.validate()
    }
    
    func save(in context: ModelContext) throws {
        validate()
        guard errors.isEmpty else { return }
        
        let user = User()
        user.name = name
        user.email = email
        context.insert(user)
        try context.save()
    }
}
```

### Localization

All error messages are localizable. Create a `Localizable.strings` file and override the default messages:

```
"email is required" = "Email address is required";
"email must be a valid email address" = "Please enter a valid email address";
"Please provide a value for email" = "Email cannot be left blank";
```

## API Documentation

Full API documentation is available at [Swift Package Index](https://swiftpackageindex.com/joelklabo/SwiftDataValidator/documentation).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. Before contributing, please:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

Make sure all tests pass and add new tests for any new functionality.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Example Project

For a complete example of using SwiftDataValidator in a real app, check out the [ViceChips](https://github.com/joelklabo/ViceChips) project where this validation framework originated.

## Acknowledgments

- Inspired by validation patterns from ActiveRecord, Vapor, and other frameworks
- Built with ❤️ using Swift 6 and SwiftData