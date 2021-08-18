//
//  MovieTableViewCell.swift
//  MovieTime
//
//  Created by obss on 30.07.2021.
//

import UIKit
import Kingfisher
import SkeletonView

class MovieTableViewCell: UITableViewCell {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var favoriteIcon: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()

        favoriteIcon.isHidden = true
        posterImageView.image = nil
    }

    func configure(with movie: Movie, favorites: [FavoriteMovie]) {
        setLabelTexts(with: movie)
        setFavoriteIcon(with: movie, favorites: favorites)
        downloadAndSetPosterImage(with: movie)
    }

    private func setFavoriteIcon(with movie: Movie, favorites: [FavoriteMovie]) {
        if let safeId = movie.id {
            if favorites.contains(where: { movie in
                movie.id == safeId
            }) {
                favoriteIcon.isHidden = false
            }
        }
    }

    private func setLabelTexts(with movie: Movie) {
        titleLabel.text = movie.title
        dateLabel.addLeading(image: UIImage(named: "calendar") ?? UIImage(), text: " \(movie.getReleaseDate())")
        ratingLabel.text = "􀋃 \(movie.getRating())"
    }

    private func downloadAndSetPosterImage(with movie: Movie) {
        let processor = RoundCornerImageProcessor(cornerRadius: 30) |> DownsamplingImageProcessor(size: posterImageView.frame.size)
        posterImageView.setImage(urlString: movie.getPosterPath(), processor: processor)
    }

}
