//
//  JSONLoader.swift
//  ServerDrivenUIDemo


import Foundation


final class JSONLoader {

    func loadForm() throws -> FormResponse {
        guard let url = Bundle.main.url(
            forResource: "sample",
            withExtension: "json"
        ) else {
            throw LoaderError.fileNotFound
        }

        let data = try Data(contentsOf: url)

        let decoder = JSONDecoder()

        return try decoder.decode(
            FormResponse.self,
            from: data
        )
    }
}

extension JSONLoader {

    enum LoaderError: LocalizedError {
        case fileNotFound
    }
}
