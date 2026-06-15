//
//  ToggleFieldModel.swift
//  ServerDrivenUIDemo



struct ToggleFieldModel: Decodable {
    let defaultValue: Bool?
    let toggleLabel: String?

    enum CodingKeys: String, CodingKey {
        case defaultValue = "default_value"
        case toggleLabel = "toggle_label"
    }
}
