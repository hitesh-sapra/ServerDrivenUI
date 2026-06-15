//
//  CheckboxComponent.swift
//  ServerDrivenUIDemo
//

import SwiftUI

struct CheckboxComponent: View {

    let field: FormField
    @Binding var isChecked: Bool
    let hasError: Bool

    @Environment(\.appTheme) private var theme

    private var checkboxModel: CheckboxFieldModel? {
        guard case .checkbox(let m) = field.fieldType else { return nil }
        return m
    }

    private var metadata: [String: String] { checkboxModel?.metadata ?? [:] }

    private var linkColor: Color {
        if let hex = checkboxModel?.clickableTextColor {
            return Color(hex: hex)
        }
        return Color(hex: theme.textColor)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Button {
                isChecked.toggle()
            } label: {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                        .font(.title3)
                        .foregroundColor(
                            isChecked
                            ? Color(hex: theme.textColor)
                            : Color(hex: theme.borderColor)
                        )

                    richLabel
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer()
                }
            }
            .buttonStyle(.plain)

            if hasError {
                Text("You must accept this to continue.")
                    .font(.caption)
                    .foregroundColor(Color(hex: theme.errorColor))
            }
        }
    }

    @ViewBuilder
    private var richLabel: some View {
        if metadata.isEmpty {
            Text(field.label)
                .foregroundColor(Color(hex: theme.textColor))
                .font(.subheadline)
        } else {
            Text(buildAttributedLabel())
                .font(.subheadline)
                .environment(\.openURL, OpenURLAction { url in
                    
                    return .systemAction
                })
        }
    }

    private func buildAttributedLabel() -> AttributedString {
        var result = AttributedString(field.label)
        result.foregroundColor = Color(hex: theme.textColor)

        for (key, urlString) in metadata {
            guard let url = URL(string: urlString) else { continue }
            
            var searchRange = result.startIndex ..< result.endIndex
            while let range = result[searchRange].range(of: key) {
                result[range].link = url
                result[range].foregroundColor = linkColor
                result[range].underlineStyle = .single
                // Advance search start past this match
                let afterMatch = range.upperBound
                guard afterMatch < result.endIndex else { break }
                searchRange = afterMatch ..< result.endIndex
            }
        }
        return result
    }
}
