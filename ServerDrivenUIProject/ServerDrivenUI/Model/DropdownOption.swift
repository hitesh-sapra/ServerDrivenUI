//
//  DropdownOption.swift
//  ServerDrivenUIDemo


struct DropdownOption: Decodable {
    let id: String
    let label: String

    enum CodingKeys: String, CodingKey {
        case id
        case label
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id    = try container.decode(String.self, forKey: .id)
        label = try container.decodeIfPresent(String.self, forKey: .label) ?? id
    }
}
