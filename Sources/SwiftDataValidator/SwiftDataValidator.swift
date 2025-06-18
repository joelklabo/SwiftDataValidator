// SwiftDataValidator provides a comprehensive validation framework for SwiftData models.
//
// ## Overview
//
// SwiftDataValidator makes it easy to add validation to your SwiftData models with a clean,
// declarative API. It provides type-safe validation rules, localized error messages, and
// seamless integration with SwiftData.
//
// ## Basic Usage
//
// Make your SwiftData model conform to `Validatable`:
//
// ```swift
// import SwiftData
// import SwiftDataValidator
//
// @Model
// final class User: Validatable {
//     var name: String = ""
//     var email: String = ""
//     var age: Int = 0
//
//     func validate() -> [ValidationError] {
//         var validator = Validator()
//
//         validator.validate(field: "name", value: name) { validator in
//             validator.required()
//             validator.notEmpty()
//             validator.maxLength(50)
//         }
//
//         validator.validate(field: "email", value: email) { validator in
//             validator.required()
//             validator.matchesEmail()
//         }
//
//         validator.validate(field: "age", value: age) { validator in
//             validator.required()
//             validator.range(min: 18, max: 120)
//         }
//
//         return validator.errors()
//     }
// }
// ```
//
// Then validate before saving:
//
// ```swift
// let user = User()
// user.name = "John Doe"
// user.email = "john@example.com"
// user.age = 25
//
// let errors = user.validate()
// if errors.isEmpty {
//     // Save to SwiftData
//     context.insert(user)
//     try context.save()
// } else {
//     // Handle validation errors
//     for error in errors {
//         print(error.localizedDescription)
//     }
// }
// ```
