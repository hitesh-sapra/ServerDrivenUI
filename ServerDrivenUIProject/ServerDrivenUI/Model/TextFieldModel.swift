//
//  TextFieldModel.swift
//  ServerDrivenUIDemo



struct TextFieldModel: Decodable {
    let subtype: TextSubtype
    let placeholder: String?
    let maxLength: Int?
    let errorMessage: String?
    let validationRegex: String?

    enum CodingKeys: String, CodingKey {
        case subtype
        case placeholder
        case maxLength = "max_length"
        case errorMessage = "error_message"
        case validationRegex = "validation_regex"
    }
    
    init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            subtype = try container.decodeIfPresent(TextSubtype.self, forKey: .subtype) ?? .plain
            placeholder = try container.decodeIfPresent(String.self, forKey: .placeholder)
            maxLength = try container.decodeIfPresent(Int.self, forKey: .maxLength)
            errorMessage = try container.decodeIfPresent(String.self, forKey: .errorMessage)
            validationRegex = try container.decodeIfPresent(String.self, forKey: .validationRegex)
        }
}
