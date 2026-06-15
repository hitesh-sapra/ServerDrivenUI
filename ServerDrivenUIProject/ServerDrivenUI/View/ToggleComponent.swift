//
//  ToggleComponent.swift
//  ServerDrivenUIDemo
//

import SwiftUI

struct ToggleComponent: View {

    let field: FormField
    @Binding var isOn: Bool
    @Environment(\.appTheme) private var theme

    private var toggleLabel: String {
        if case .toggle(let model) = field.fieldType,
           let custom = model.toggleLabel, !custom.isEmpty {
            return custom
        }
        return field.label
    }

    var body: some View {
        Toggle(isOn: $isOn) {
            Text(toggleLabel)
                .font(.subheadline.weight(.medium))
                .foregroundColor(Color(hex: theme.textColor))
        }
        .tint(Color(hex: theme.textColor))
    }
}
