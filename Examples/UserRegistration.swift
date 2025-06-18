import SwiftData
import SwiftDataValidator
import Foundation

// MARK: - Example: User Registration Form

@Model
final class UserRegistration: Validatable {
    var username: String = ""
    var email: String = ""
    var password: String = ""
    var confirmPassword: String = ""
    var phoneNumber: String?
    var birthDate: Date?
    var agreeToTerms: Bool = false
    var website: String?
    
    func validate() -> [ValidationError] {
        var validator = Validator()
        
        // Username validation
        validator.validate(field: "username", value: username) { validator in
            validator.required()
            validator.notEmpty()
            validator.minLength(3)
            validator.maxLength(20)
            validator.custom({ username in
                // Check if username contains only alphanumeric characters
                guard let username else { return false }
                let alphanumeric = CharacterSet.alphanumerics
                return username.rangeOfCharacter(from: alphanumeric.inverted) == nil
            }, error: .invalidFormat(reason: "must contain only letters and numbers"))
        }
        
        // Email validation
        validator.validate(field: "email", value: email) { validator in
            validator.required()
            validator.notEmpty()
            validator.matchesEmail()
        }
        
        // Password validation
        validator.validate(field: "password", value: password) { validator in
            validator.required()
            validator.minLength(8)
            validator.maxLength(128)
            validator.custom({ password in
                // Ensure password has at least one uppercase, one lowercase, and one number
                guard let password else { return false }
                let hasUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
                let hasLowercase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
                let hasNumber = password.rangeOfCharacter(from: .decimalDigits) != nil
                return hasUppercase && hasLowercase && hasNumber
            }, error: .invalidFormat(reason: "must contain uppercase, lowercase, and number"))
        }
        
        // Confirm password validation
        validator.validate(field: "confirmPassword", value: confirmPassword) { validator in
            validator.required()
            validator.matches(password, fieldName: "password")
        }
        
        // Optional phone number validation
        if let phoneNumber = phoneNumber, !phoneNumber.isEmpty {
            validator.validate(field: "phoneNumber", value: phoneNumber) { validator in
                validator.matchesPhoneNumber()
            }
        }
        
        // Birth date validation (must be 18+ years old)
        if let birthDate = birthDate {
            validator.validate(field: "birthDate", value: birthDate) { validator in
                validator.notFuture()
                validator.custom({ date in
                    guard let date else { return false }
                    let calendar = Calendar.current
                    let ageComponents = calendar.dateComponents([.year], from: date, to: Date())
                    return (ageComponents.year ?? 0) >= 18
                }, error: .businessRule(reason: "You must be at least 18 years old"))
            }
        }
        
        // Website validation (optional)
        if let website = website, !website.isEmpty {
            validator.validate(field: "website", value: website) { validator in
                validator.matchesURL()
            }
        }
        
        // Terms agreement validation
        validator.validate(field: "agreeToTerms", value: agreeToTerms) { validator in
            validator.custom({ agreed in
                agreed == true
            }, error: .businessRule(reason: "You must agree to the terms and conditions"))
        }
        
        return validator.errors()
    }
}

// MARK: - Usage Example

func registerUser(in context: ModelContext) {
    let registration = UserRegistration()
    registration.username = "johndoe123"
    registration.email = "john.doe@example.com"
    registration.password = "SecurePass123"
    registration.confirmPassword = "SecurePass123"
    registration.phoneNumber = "+1 (555) 123-4567"
    registration.birthDate = Calendar.current.date(byAdding: .year, value: -25, to: Date())
    registration.website = "https://johndoe.com"
    registration.agreeToTerms = true
    
    // Validate the registration
    let errors = registration.validate()
    
    if errors.isEmpty {
        // All validation passed - save to database
        context.insert(registration)
        do {
            try context.save()
            print("✅ User registered successfully!")
        } catch {
            print("❌ Failed to save: \(error)")
        }
    } else {
        // Handle validation errors
        print("❌ Validation failed with \(errors.count) error(s):")
        for error in errors {
            print("  - \(error.field): \(error.localizedDescription)")
            if let suggestion = error.recoverySuggestion {
                print("    💡 \(suggestion)")
            }
        }
    }
}

// MARK: - SwiftUI Integration Example

import SwiftUI

struct RegistrationView: View {
    @State private var registration = UserRegistration()
    @State private var validationErrors: [ValidationError] = []
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Form {
            Section("Account Information") {
                TextField("Username", text: $registration.username)
                    .textContentType(.username)
                    .autocapitalization(.none)
                
                TextField("Email", text: $registration.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                SecureField("Password", text: $registration.password)
                    .textContentType(.newPassword)
                
                SecureField("Confirm Password", text: $registration.confirmPassword)
                    .textContentType(.newPassword)
            }
            
            Section("Optional Information") {
                TextField("Phone Number", text: Binding(
                    get: { registration.phoneNumber ?? "" },
                    set: { registration.phoneNumber = $0.isEmpty ? nil : $0 }
                ))
                .textContentType(.telephoneNumber)
                .keyboardType(.phonePad)
                
                DatePicker("Birth Date", 
                    selection: Binding(
                        get: { registration.birthDate ?? Date() },
                        set: { registration.birthDate = $0 }
                    ),
                    displayedComponents: .date
                )
                
                TextField("Website", text: Binding(
                    get: { registration.website ?? "" },
                    set: { registration.website = $0.isEmpty ? nil : $0 }
                ))
                .textContentType(.URL)
                .keyboardType(.URL)
                .autocapitalization(.none)
            }
            
            Section {
                Toggle("I agree to the terms and conditions", isOn: $registration.agreeToTerms)
            }
            
            Section {
                Button("Register") {
                    register()
                }
                .disabled(!validationErrors.isEmpty)
            }
            
            if !validationErrors.isEmpty {
                Section("Validation Errors") {
                    ForEach(validationErrors, id: \.self) { error in
                        Label {
                            VStack(alignment: .leading) {
                                Text(error.localizedDescription)
                                    .foregroundColor(.red)
                                if let suggestion = error.recoverySuggestion {
                                    Text(suggestion)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        } icon: {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .onChange(of: registration.username) { _, _ in validateForm() }
        .onChange(of: registration.email) { _, _ in validateForm() }
        .onChange(of: registration.password) { _, _ in validateForm() }
        .onChange(of: registration.confirmPassword) { _, _ in validateForm() }
        .onChange(of: registration.agreeToTerms) { _, _ in validateForm() }
    }
    
    private func validateForm() {
        validationErrors = registration.validate()
    }
    
    private func register() {
        validationErrors = registration.validate()
        
        guard validationErrors.isEmpty else { return }
        
        modelContext.insert(registration)
        do {
            try modelContext.save()
            // Handle successful registration
        } catch {
            // Handle save error
        }
    }
}