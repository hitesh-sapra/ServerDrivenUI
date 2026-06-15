//
//  DropdownFieldModel.swift
//  ServerDrivenUIDemo
//

struct DropdownFieldModel: Decodable {
    let options: [DropdownOption]
    let allowMultiple: Bool
    let defaultValues: [String]
    let errorMessage: String?          

    enum CodingKeys: String, CodingKey {
        case options
        case allowMultiple  = "allow_multiple"
        case defaultValues  = "default_values"
        case errorMessage   = "error_message"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        options = try container.decodeIfPresent(
            [DropdownOption].self,
            forKey: .options
        ) ?? []

        allowMultiple = try container.decodeIfPresent(
            Bool.self,
            forKey: .allowMultiple
        ) ?? false

        defaultValues = try container.decodeIfPresent(
            [String].self,
            forKey: .defaultValues
        ) ?? []

        errorMessage = try container.decodeIfPresent(
            String.self,
            forKey: .errorMessage
        )
    }
}
