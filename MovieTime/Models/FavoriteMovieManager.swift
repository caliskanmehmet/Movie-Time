//
//  FavoriteMovieManager.swift
//  MovieTime
//
//  Created by obss on 14.08.2021.
//

import Foundation

class FavoriteMovieManager {

    static let shared = FavoriteMovieManager()
    private let notificationCenter: NotificationCenter
    var favoriteMovies: [FavoriteMovie] = []

    init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter

        favoriteMovies = fetchFavoriteMovies()
    }

    func saveFavoriteMovies(movies: [FavoriteMovie]) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(movies), forKey: "favorites")

        favoriteMovies = movies

        notificationCenter.post(name: .moviesChanged, object: movies)
    }

    private func fetchFavoriteMovies() -> [FavoriteMovie] {

        if let data = UserDefaults.standard.value(forKey: "favorites") as? Data {
            return (try? PropertyListDecoder().decode(Array<FavoriteMovie>.self, from: data)) ?? []
        }

        return []
    }
}

// MARK: - Notification.Name Extension

extension Notification.Name {
    static var moviesChanged: Notification.Name {
        return .init(rawValue: "FavoriteMovieManager.moviesChanged")
    }
}
