//
//  TextSubtype.swift
//  ServerDrivenUIDemo



enum TextSubtype: String, Decodable {
    case plain = "PLAIN"
    case multiline = "MULTILINE"
    case number = "NUMBER"
    case uri = "URI"
    case secure = "SECURE"
}
