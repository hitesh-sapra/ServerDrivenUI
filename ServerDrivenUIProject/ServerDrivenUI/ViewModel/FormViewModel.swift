//
//  FormViewModel.swift
//  ServerDrivenUIDemo
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class FormViewModel: ObservableObject {

    @Published private(set) var form: FormResponse?
    @Published private(set) var errorMessage: String?
    @Published private(set) var submissionSummary: String?

    @Published var fieldValues: [String: FieldValue] = [:]
    @Published var validationErrors: [String: Bool] = [:]

    private let loader = JSONLoader()

    var sortedFields: [FormField] { form?.fields ?? [] }

    func loadForm() {
        do {
            let response = try loader.loadForm()
            let sortedFields = response.fields.sorted { $0.order < $1.order }
            form = FormResponse(
                theme: response.theme,
                formTitle: response.formTitle,
                fields: sortedFields
            )
            seedDefaultValues()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func seedDefaultValues() {
        guard let fields = form?.fields else { return }
        for field in fields {
            switch field.fieldType {
            case .text:
                fieldValues[field.id] = .text("")
            case .dropdown(let model):
                fieldValues[field.id] = .dropdown(model.defaultValues)
            case .toggle(let model):
                fieldValues[field.id] = .toggle(model.defaultValue ?? false)
            case .checkbox:
                fieldValues[field.id] = .checkbox(false)
            case .unknown:
                break
            }
        }
    }

    // MARK: - Bindings

    func textBinding(for id: String) -> Binding<String> {
        Binding(
            get: {
                guard case .text(let v) = self.fieldValues[id] else { return "" }
                return v
            },
            set: {
                self.fieldValues[id] = .text($0)
                self.validationErrors.removeValue(forKey: id)
            }
        )
    }

    func dropdownBinding(for id: String) -> Binding<[String]> {
        Binding(
            get: {
                guard case .dropdown(let v) = self.fieldValues[id] else { return [] }
                return v
            },
            set: {
                self.fieldValues[id] = .dropdown($0)
                self.validationErrors.removeValue(forKey: id)
            }
        )
    }

    func toggleBinding(for id: String) -> Binding<Bool> {
        Binding(
            get: {
                guard case .toggle(let v) = self.fieldValues[id] else { return false }
                return v
            },
            set: { self.fieldValues[id] = .toggle($0) }
        )
    }

    func checkboxBinding(for id: String) -> Binding<Bool> {
        Binding(
            get: {
                guard case .checkbox(let v) = self.fieldValues[id] else { return false }
                return v
            },
            set: {
                self.fieldValues[id] = .checkbox($0)
                self.validationErrors.removeValue(forKey: id)
            }
        )
    }

    // MARK: - Validation & Submission

    @discardableResult
    func validateAndSubmit() -> Bool {
        validationErrors = [:]
        var isValid = true

        for field in sortedFields {
            switch fieldValues[field.id] {

            case .text(let s):
                let trimmed = s.trimmingCharacters(in: .whitespaces)

                // 1. Required empty check
                if field.required && trimmed.isEmpty {
                    validationErrors[field.id] = true
                    isValid = false
                    continue   
                }
                
                if !trimmed.isEmpty,
                   case .text(let textModel) = field.fieldType,
                   let pattern = textModel.validationRegex {
                    if !matches(pattern: pattern, input: trimmed) {
                        validationErrors[field.id] = true
                        isValid = false
                    }
                }

            case .dropdown(let ids):
                if field.required && ids.isEmpty {
                    validationErrors[field.id] = true
                    isValid = false
                }

            case .checkbox(let checked):
                if field.required && !checked {
                    validationErrors[field.id] = true
                    isValid = false
                }

            case .toggle:
                // A false toggle is a valid conscious choice — never mark invalid
                break

            case nil:
                if field.required {
                    validationErrors[field.id] = true
                    isValid = false
                }
            }
        }

        if isValid { printSubmissionOutput() }
        return isValid
    }

    // MARK: - Single-field blur validation
    // Called by TextFieldComponent when the user leaves a field.
    // Runs regex only — the empty/required check is intentionally skipped here
    // so required fields don't fire before the user has ever touched Save.
    func validateField(_ field: FormField) {
        guard case .text(let textModel) = field.fieldType,
              let pattern = textModel.validationRegex else { return }

        guard case .text(let s) = fieldValues[field.id] else { return }
        let trimmed = s.trimmingCharacters(in: .whitespaces)

        // Empty value on blur: clear error — don't punish an untouched optional field
        if trimmed.isEmpty {
            validationErrors.removeValue(forKey: field.id)
            return
        }

        if matches(pattern: pattern, input: trimmed) {
            validationErrors.removeValue(forKey: field.id)
        } else {
            validationErrors[field.id] = true
        }
    }

    // MARK: - Regex helper

    /// Returns true when `input` satisfies `pattern` (full-string match anchored with ^ and $).
    private func matches(pattern: String, input: String) -> Bool {
        // Anchor the pattern so partial matches don't pass (e.g. "abc123" shouldn't
        // match a pattern that only requires digits if the server omits anchors).
        let anchored = "^\(pattern)$"
        guard let regex = try? NSRegularExpression(pattern: anchored) else {
            // Malformed regex from the server — fail open (don't block the user)
            return true
        }
        let range = NSRange(input.startIndex..., in: input)
        return regex.firstMatch(in: input, range: range) != nil
    }

    // MARK: - Submission output

    private func printSubmissionOutput() {
        // Build ordered key-value pairs using field order from the form
        // so the summary reads top-to-bottom, not in random dict order.
        var lines: [String] = []
        for field in sortedFields {
            guard let value = fieldValues[field.id] else { continue }
            let displayKey = field.label.isEmpty ? field.id : field.label
            switch value {
            case .text(let s)       where !s.isEmpty:
                lines.append("\(displayKey): \(s)")
            case .dropdown(let ids) where !ids.isEmpty:
                // Resolve ids back to human-readable labels where possible
                let labels: [String]
                if case .dropdown(let model) = field.fieldType {
                    labels = ids.compactMap { id in model.options.first { $0.id == id }?.label ?? id }
                } else {
                    labels = ids
                }
                lines.append("\(displayKey): \(labels.joined(separator: ", "))")
            case .toggle(let b):
                lines.append("\(displayKey): \(b ? "On" : "Off")")
            case .checkbox(let b):
                lines.append("\(displayKey): \(b ? "✓" : "✗")")
            default:
                break
            }
        }
        submissionSummary = lines.joined(separator: "\n")

        // Also print raw JSON to console as before
        var output: [String: Any] = [:]
        for (id, value) in fieldValues {
            switch value {
            case .text(let s):       output[id] = s
            case .dropdown(let ids): output[id] = ids
            case .toggle(let b):     output[id] = b
            case .checkbox(let b):   output[id] = b
            }
        }
        if let data = try? JSONSerialization.data(withJSONObject: output, options: .prettyPrinted),
           let json = String(data: data, encoding: .utf8) {
            print("Form Submission:\n\(json)")
        }
    }
}
