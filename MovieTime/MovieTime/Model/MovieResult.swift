//
//  Movies.swift
//  MovieTime
//
//  Created by obss on 30.07.2021.
//

import Foundation

struct MovieResult: Codable {
    let page: Int?
    let results: [Movie]?
}

struct Movie: Codable, Identifiable {
    let posterPath: String?
    let adult: Bool?
    let overview: String?
    let releaseDate: String?
    let genreIds: [Int]?
    let id: Int?
    let originalTitle: String?
    let originalLanguage: String?
    let title: String?
    let backdropPath: String?
    let popularity: Float?
    let voteCount: Int?
    let video: Bool?
    let voteAverage: Float?

    func getPosterPath() -> String? {
        if let safePath = posterPath {
            return "https://image.tmdb.org/t/p/w500\(safePath)"
        } else {
            return nil
        }
    }
}
