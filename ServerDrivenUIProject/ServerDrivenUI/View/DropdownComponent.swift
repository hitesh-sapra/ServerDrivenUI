//
//  DropdownComponent.swift
//  ServerDrivenUIDemo
//

import SwiftUI

struct DropdownComponent: View {

    let field: FormField
    @ObservedObject var viewModel: FormViewModel
    @Environment(\.appTheme) private var theme

    private var model: DropdownFieldModel? {
        guard case .dropdown(let m) = field.fieldType else { return nil }
        return m
    }

    private var hasError: Bool {
        viewModel.validationErrors[field.id] == true
    }

    private var errorMessage: String {
        model?.errorMessage ?? "Please select at least one option."
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Label row
            HStack(spacing: 2) {
                Text(field.label)
                    .foregroundColor(Color(hex: theme.textColor))
                if field.required {
                    Text("*").foregroundColor(Color(hex: theme.errorColor))
                }
            }
            .font(.subheadline.weight(.medium))

            if let model {
                if model.allowMultiple {
                    MultiSelectDropdown(
                        options: model.options,
                        selectedIds: viewModel.dropdownBinding(for: field.id),
                        theme: theme,
                        hasError: hasError
                    )
                } else {
                    SingleSelectDropdown(
                        options: model.options,
                        selectedIds: viewModel.dropdownBinding(for: field.id),
                        theme: theme,
                        hasError: hasError
                    )
                }
            }

            // Show error message (from JSON or fallback) only when validation failed
            if hasError {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(Color(hex: theme.errorColor))
            }
        }
    }
}

// MARK: - Single Select

private struct SingleSelectDropdown: View {
    let options: [DropdownOption]
    @Binding var selectedIds: [String]
    let theme: Theme
    let hasError: Bool

    private var selectedLabel: String {
        options.first(where: { $0.id == selectedIds.first })?.label ?? "Select…"
    }

    var body: some View {
        Menu {
            ForEach(options, id: \.id) { option in
                Button {
                    selectedIds = [option.id]
                } label: {
                    HStack {
                        Text(option.label)
                        if selectedIds.contains(option.id) {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(selectedLabel)
                    .foregroundColor(
                        selectedIds.isEmpty
                        ? Color(hex: theme.textColor).opacity(0.4)
                        : Color(hex: theme.textColor)
                    )
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .foregroundColor(Color(hex: theme.textColor).opacity(0.6))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(hex: theme.backgroundColor))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        hasError ? Color(hex: theme.errorColor) : Color(hex: theme.borderColor),
                        lineWidth: 1
                    )
            )
        }
    }
}

// MARK: - Multi Select

private struct MultiSelectDropdown: View {
    let options: [DropdownOption]
    @Binding var selectedIds: [String]
    let theme: Theme
    let hasError: Bool

    @State private var isExpanded = false

    private var summaryLabel: String {
        if selectedIds.isEmpty { return "Select…" }
        return options
            .filter { selectedIds.contains($0.id) }
            .map(\.label)
            .joined(separator: ", ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Collapsed header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(summaryLabel)
                        .foregroundColor(
                            selectedIds.isEmpty
                            ? Color(hex: theme.textColor).opacity(0.4)
                            : Color(hex: theme.textColor)
                        )
                        .lineLimit(1)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(Color(hex: theme.textColor).opacity(0.6))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color(hex: theme.backgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            hasError ? Color(hex: theme.errorColor) : Color(hex: theme.borderColor),
                            lineWidth: 1
                        )
                )
            }
            .buttonStyle(.plain)

            // Expanded options list
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(options, id: \.id) { option in
                        let isSelected = selectedIds.contains(option.id)
                        Button {
                            if isSelected {
                                selectedIds.removeAll { $0 == option.id }
                            } else {
                                selectedIds.append(option.id)
                            }
                        } label: {
                            HStack {
                                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                                    .foregroundColor(
                                        isSelected
                                        ? Color(hex: theme.textColor)
                                        : Color(hex: theme.borderColor)
                                    )
                                Text(option.label)
                                    .foregroundColor(Color(hex: theme.textColor))
                                Spacer()
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)

                        if option.id != options.last?.id {
                            Divider()
                                .background(Color(hex: theme.borderColor))
                        }
                    }
                }
                .background(Color(hex: theme.backgroundColor))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(hex: theme.borderColor), lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}
