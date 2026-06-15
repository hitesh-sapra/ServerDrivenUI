//
//  DynamicFieldView.swift
//  ServerDrivenUIDemo
//

import SwiftUI

struct DynamicFieldView: View {

    let field: FormField

    @ObservedObject
    var viewModel: FormViewModel

    var body: some View {
        switch field.fieldType {

        case .text(let model):
            TextFieldComponent(
                field: field,
                model: model,
                value: viewModel.textBinding(for: field.id),
                hasError: viewModel.validationErrors[field.id] == true
            )

        case .dropdown:
            DropdownComponent(
                field: field,
                viewModel: viewModel
            )

        case .toggle:
            ToggleComponent(
                field: field,
                isOn: viewModel.toggleBinding(for: field.id)
            )

        case .checkbox:
            CheckboxComponent(
                field: field,
                isChecked: viewModel.checkboxBinding(for: field.id),
                hasError: viewModel.validationErrors[field.id] == true
            )

        case .unknown:
            EmptyView()
        }
    }
}
