//
//  GenreManager.swift
//  MovieTime
//
//  Created by obss on 3.08.2021.
//

import Foundation
import Alamofire

class GenreManager {
    static let shared = GenreManager()
    var genres: [Genre]?

    func getGenres(completion: @escaping (Result<GenreResult, AFError>) -> Void) {
        let request = AF.request(NetworkConstants.genres, encoding: URLEncoding(destination: .queryString))
        let decoder = JSONDecoder()

        request.responseDecodable(of: GenreResult.self, decoder: decoder) { response in
            completion(response.result)
        }
    }
}
