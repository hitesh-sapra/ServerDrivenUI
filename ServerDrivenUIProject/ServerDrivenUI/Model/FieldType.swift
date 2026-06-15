//
//  FieldType.swift
//  ServerDrivenUIDemo



enum FieldType: Decodable {
    case text(TextFieldModel)
    case dropdown(DropdownFieldModel)
    case toggle(ToggleFieldModel)
    case checkbox(CheckboxFieldModel)
    case unknown
    
    enum CodingKeys: String, CodingKey { case type }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "TEXT":     self = .text(try TextFieldModel(from: decoder))
        case "DROPDOWN": self = .dropdown(try DropdownFieldModel(from: decoder))
        case "TOGGLE":   self = .toggle(try ToggleFieldModel(from: decoder))
        case "CHECKBOX": self = .checkbox(try CheckboxFieldModel(from: decoder))
        default:         self = .unknown
        }
        
    }
}
