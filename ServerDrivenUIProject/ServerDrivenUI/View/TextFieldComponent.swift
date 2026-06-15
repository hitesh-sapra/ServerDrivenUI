//
//  TextFieldComponent.swift
//  ServerDrivenUIDemo
//

import SwiftUI

struct TextFieldComponent: View {

    let field: FormField
    let model: TextFieldModel

    @Binding var value: String
    let hasError: Bool

    @Environment(\.appTheme) private var theme

    private var remainingChars: Int? {
        guard let max = model.maxLength else { return nil }
        return max - value.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 2) {
                Text(field.label)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(Color(hex: theme.textColor))
                if field.required {
                    Text("*")
                        .foregroundColor(Color(hex: theme.errorColor))
                }
                Spacer()
                if let remaining = remainingChars {
                    Text("\(remaining)")
                        .font(.caption2.monospacedDigit())
                        .foregroundColor(
                            remaining <= 0
                            ? Color(hex: theme.errorColor)
                            : Color(hex: theme.textColor).opacity(0.45)
                        )
                }
            }

            inputField

            if hasError, let msg = model.errorMessage {
                Text(msg)
                    .font(.caption)
                    .foregroundColor(Color(hex: theme.errorColor))
            }
        }
    }

    @ViewBuilder
    private var inputField: some View {
        let borderColor = hasError
            ? Color(hex: theme.errorColor)
            : Color(hex: theme.borderColor)

        switch model.subtype {

        case .multiline:
            TextEditor(text: $value)
                .frame(minHeight: 100)
                .scrollContentBackground(.hidden)
                .background(Color(hex: theme.backgroundColor))
                .foregroundColor(Color(hex: theme.textColor))
                .padding(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: 1)
                )
                
                .onChange(of: value) { newValue in
                    if let max = model.maxLength, newValue.count > max {
                        value = String(newValue.prefix(max))
                    }
                }

        case .secure:
            SecureField(model.placeholder ?? "", text: $value)
                .themedFieldStyle(
                    textColor: Color(hex: theme.textColor),
                    bgColor: Color(hex: theme.backgroundColor),
                    borderColor: borderColor
                )
                .onChange(of: value) { newValue in
                    if let max = model.maxLength, newValue.count > max {
                        value = String(newValue.prefix(max))
                    }
                }

        case .number:
            TextField(model.placeholder ?? "", text: $value)
                .keyboardType(.decimalPad)
                .themedFieldStyle(
                    textColor: Color(hex: theme.textColor),
                    bgColor: Color(hex: theme.backgroundColor),
                    borderColor: borderColor
                )
                .onChange(of: value) { newValue in
                    var filtered = newValue.filter { $0.isNumber || $0 == "." }
                    
                    var foundDot = false
                    filtered = String(filtered.filter { char in
                        if char == "." {
                            if foundDot { return false }
                            foundDot = true
                        }
                        return true
                    })
                    if let max = model.maxLength, filtered.count > max {
                        filtered = String(filtered.prefix(max))
                    }
                    if filtered != newValue { value = filtered }
                }

        case .uri:
            TextField(model.placeholder ?? "", text: $value)
                .keyboardType(.URL)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .themedFieldStyle(
                    textColor: Color(hex: theme.textColor),
                    bgColor: Color(hex: theme.backgroundColor),
                    borderColor: borderColor
                )
                
                .onChange(of: value) { newValue in
                    var filtered = newValue.filter { !$0.isWhitespace }
                    if let max = model.maxLength, filtered.count > max {
                        filtered = String(filtered.prefix(max))
                    }
                    if filtered != newValue { value = filtered }
                }

        case .plain:
            TextField(model.placeholder ?? "", text: $value)
                .themedFieldStyle(
                    textColor: Color(hex: theme.textColor),
                    bgColor: Color(hex: theme.backgroundColor),
                    borderColor: borderColor
                )
                .onChange(of: value) { newValue in
                    if let max = model.maxLength, newValue.count > max {
                        value = String(newValue.prefix(max))
                    }
                }
        }
    }
}

// MARK: - Reusable themed text-field modifier

private struct ThemedFieldStyle: ViewModifier {
    let textColor: Color
    let bgColor: Color
    let borderColor: Color

    func body(content: Content) -> some View {
        content
            .foregroundColor(textColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(bgColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(borderColor, lineWidth: 1)
            )
    }
}

private extension View {
    func themedFieldStyle(textColor: Color, bgColor: Color, borderColor: Color) -> some View {
        self.modifier(ThemedFieldStyle(
            textColor: textColor,
            bgColor: bgColor,
            borderColor: borderColor
        ))
    }
}
