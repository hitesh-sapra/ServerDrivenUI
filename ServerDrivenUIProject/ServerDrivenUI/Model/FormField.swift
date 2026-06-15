//
//  FormField.swift
//  ServerDrivenUIDemo


struct FormField: Decodable {
    let id: String
    let order: Int
    let label: String       
    let required: Bool
    let fieldType: FieldType

    enum CodingKeys: String, CodingKey {
        case id
        case order
        case label
        case required
        case fieldType = "type"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // id and order are structural — without them the field cannot be identified
        // or sorted, so a missing key here is genuinely corrupt data; let it throw.
        id    = try container.decode(String.self, forKey: .id)
        order = try container.decode(Int.self,    forKey: .order)

        // label is display-only; fall back to empty string rather than crashing
        label    = try container.decodeIfPresent(String.self, forKey: .label)    ?? ""
        required = try container.decodeIfPresent(Bool.self,   forKey: .required) ?? false

        fieldType = try FieldType(from: decoder)
    }
}
