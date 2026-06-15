//
//  CheckboxFieldModel.swift
//  ServerDrivenUIDemo



struct CheckboxFieldModel: Decodable {
    let metadata: [String: String]?
    let clickableTextColor: String?

    enum CodingKeys: String, CodingKey {
        case metadata
        case clickableTextColor = "clickable_text_color"
    }
}
