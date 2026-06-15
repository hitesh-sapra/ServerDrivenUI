//
//  FormResponse.swift
//  ServerDrivenUIDemo



struct FormResponse: Decodable {
    let theme: Theme
    let formTitle: String
    let fields: [FormField]

    enum CodingKeys: String, CodingKey {
        case theme
        case fields
        case formTitle = "form_title"
    }
}
