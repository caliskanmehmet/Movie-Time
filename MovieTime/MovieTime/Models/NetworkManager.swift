//
//  APIManager.swift
//  MovieTime
//
//  Created by obss on 14.08.2021.
//

import Foundation
import Alamofire

class NetworkManager {
    var isFetching = false

    static let shared = NetworkManager()

    func fetchData<T: Codable>(urlRequest: URLRequestConvertible, type: T.Type, onCompletion: @escaping (Result<T, AFError>) -> Void) {
        isFetching = true

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        AF.request(urlRequest).responseDecodable(of: T.self, decoder: decoder) { response in
            onCompletion(response.result)
            self.isFetching = false
        }
    }
}
