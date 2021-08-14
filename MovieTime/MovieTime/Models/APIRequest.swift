//
//  APIRequest.swift
//  MovieTime
//
//  Created by obss on 14.08.2021.
//

import Foundation
import Alamofire

enum APIRequest: URLRequestConvertible {

    static let endpoint = URL(string: "https://api.themoviedb.org/3")
    static let apiKey = "e5cd56963b11843007db1b94312b521a"

    case getPopularMovies(pageNumber: Int)
    case searchMovies(pageNumber: Int, query: String)
    case getMovieDetails(movieId: Int)

    var path: String {
        switch self {
        case .getPopularMovies(_):
            return "/movie/popular"
        case .searchMovies(_, _):
            return "search/movie"
        case .getMovieDetails(let movieId):
            return "/movie/\(movieId)"
        }
    }

    var method: HTTPMethod {
        return .get
    }

    var encoding: URLEncoding {
        return .queryString
    }

    var languageCode: String {
        return Locale.current.languageCode ?? "en"
    }

    func asURLRequest() throws -> URLRequest {
        guard let safeUrl = APIRequest.endpoint?.appendingPathComponent(path) else { throw URLError.urlError("Error during URL init") }
        var request = URLRequest(url: safeUrl)
        request.httpMethod = method.rawValue

        var parameters = Parameters()
        parameters["api_key"] = APIRequest.apiKey
        parameters["language"] = languageCode

        switch self {
        case .getPopularMovies(let pageNumber):
            parameters["page"] = pageNumber
        case .searchMovies(let pageNumber, let query):
            parameters["page"] = pageNumber
            parameters["query"] = query
        default:
            break
        }

        request = try encoding.encode(request, with: parameters)
        return request
    }

}

enum URLError: Error {
    case urlError(String)
}
