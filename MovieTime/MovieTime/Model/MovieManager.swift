//
//  MovieManager.swift
//  MovieTime
//
//  Created by obss on 30.07.2021.
//

import Foundation
import Alamofire

struct NetworkConstants {
    static let apiKey = "e5cd56963b11843007db1b94312b521a"
    static let popularMovies = "https://api.themoviedb.org/3/movie/popular?api_key=e5cd56963b11843007db1b94312b521a&language=en-US"
    static let searchMovies = "https://api.themoviedb.org/3/search/movie?api_key=e5cd56963b11843007db1b94312b521a&language=en-US"
    static let getMovieDetails = "https://api.themoviedb.org/3/movie/"
    static let genres = "https://api.themoviedb.org/3/genre/movie/list?api_key=e5cd56963b11843007db1b94312b521a"
}

class MovieManager {

    static let shared = MovieManager()
    var isFetching = false

    func getPopularMovies(pageNumber: Int, completion: @escaping (Result<MovieResult, AFError>) -> Void) {
        isFetching = true
        let parameters: Parameters = ["page": pageNumber]
        let request = AF.request(NetworkConstants.popularMovies, parameters: parameters, encoding: URLEncoding(destination: .queryString))
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        request.responseDecodable(of: MovieResult.self, decoder: decoder) { response in
            completion(response.result)
            self.isFetching = false
        }
    }

    func searchMovies(pageNumber: Int, query: String, completion: @escaping (Result<MovieResult, AFError>) -> Void) {
        isFetching = true
        let parameters: Parameters = ["page": pageNumber, "query": query]
        let request = AF.request(NetworkConstants.searchMovies, parameters: parameters, encoding: URLEncoding(destination: .queryString))
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        request.responseDecodable(of: MovieResult.self, decoder: decoder) { response in
            completion(response.result)
            self.isFetching = false
        }
    }

    func getMovieDetails(id: Int, completion: @escaping (Result<Movie, AFError>) -> Void) {
        isFetching = true
        let parameters: Parameters = ["api_key": NetworkConstants.apiKey]
        let request = AF.request("\(NetworkConstants.getMovieDetails)\(id)", parameters: parameters, encoding: URLEncoding(destination: .queryString))
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        request.responseDecodable(of: Movie.self, decoder: decoder) { response in
            completion(response.result)
            self.isFetching = false
        }
    }

}
