//
//  GenreResult.swift
//  MovieTime
//
//  Created by obss on 3.08.2021.
//

import Foundation

struct GenreResult: Codable {
    let genres: [Genre]?
}

struct Genre: Codable {
    let id: Int?
    let name: String?
}
