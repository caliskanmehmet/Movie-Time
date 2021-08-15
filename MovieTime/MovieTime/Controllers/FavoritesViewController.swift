//
//  FavoritesViewController.swift
//  MovieTime
//
//  Created by obss on 30.07.2021.
//

import UIKit

class FavoritesViewController: UIViewController {
    @IBOutlet weak var favoriteCollectionView: UICollectionView! {
        didSet {
            favoriteCollectionView.dataSource = self
            favoriteCollectionView.delegate = self
        }
    }

    let cellId = "FavoriteCollectionViewCell"
    var favoriteMovies: [FavoriteMovie] = [] {
        didSet {
            favoriteCollectionView.backgroundView?.alpha = favoriteMovies.count > 0 ? 1.0 : 0.0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(moviesChanged),
                                               name: .moviesChanged,
                                               object: nil)

        favoriteMovies = FavoriteMovieManager.shared.favoriteMovies
    }

    @objc private func moviesChanged(_ notification: Notification) {
        guard let items = notification.object as? [FavoriteMovie] else {
            let object = notification.object as Any
            assertionFailure("Invalid object: \(object)")
            return
        }

        favoriteMovies = items
        favoriteCollectionView.reloadData()
    }

}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension FavoritesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if favoriteMovies.count == 0 {
            collectionView.setEmptyMessage(Constants.NO_FAVORITE_MOVIE)
        } else {
            collectionView.restore()
        }

        return favoriteMovies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? FavoriteCollectionViewCell
        if let safeCell = cell {
            safeCell.configure(with: favoriteMovies[indexPath.row])

            return safeCell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailVC = DetailViewController()

        detailVC.favoriteMovies = favoriteMovies
        detailVC.movieId = favoriteMovies[indexPath.row].id

        navigationController?.pushViewController(detailVC, animated: true)
    }

}
