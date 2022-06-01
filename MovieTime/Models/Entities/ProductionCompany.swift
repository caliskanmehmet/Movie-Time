//
//  ProductionCompany.swift
//  MovieTime
//
//  Created by Mehmet Caliskan on 12.08.2021.
//

import Foundation

struct ProductionCompany: Codable {
    let id: Int?
    let logoPath: String?
    let name: String?
    let originCountry: String?

    func getLogoPath() -> String? {
        if let safePath = logoPath {
            return "https://image.tmdb.org/t/p/w154\(safePath)"
        } else {
            return nil
        }
    }
}
