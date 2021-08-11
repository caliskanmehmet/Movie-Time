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

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        favoriteIcon.isHidden = true
    }

    func resetContents() {
        posterImageView.image = UIImage(named: "placeholder")
        titleLabel.text = ""
        ratingLabel.text = ""
        dateLabel.text = ""
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
        titleLabel.showGradientSkeleton()
        ratingLabel.showGradientSkeleton()
        dateLabel.showGradientSkeleton()

        titleLabel.text = movie.title // 􀉉􀉉
        // dateLabel.text = "􀒏 \(movie.getReleaseDate())"

        dateLabel.addLeading(image: UIImage(named: "calendar") ?? UIImage(), text: " \(movie.getReleaseDate())")
        ratingLabel.text = "􀋃 \(movie.getRating())"
        // ratingLabel.addLeading(image: UIImage(named: "star.fill") ?? UIImage(), text: " \(movie.getRating())")

        titleLabel.hideSkeleton()
        ratingLabel.hideSkeleton()
        dateLabel.hideSkeleton()
    }

    private func downloadAndSetPosterImage(with movie: Movie) {
        posterImageView.showAnimatedSkeleton()

        let processor = RoundCornerImageProcessor(cornerRadius: 30) |> DownsamplingImageProcessor(size: posterImageView.frame.size)

        if let safeUrl = movie.getPosterPath() {
            posterImageView.kf.setImage(with: URL(string: safeUrl), options: [.processor(processor),
                                                                              .scaleFactor(UIScreen.main.scale),
                                                                              .cacheOriginalImage,
                                                                              .cacheSerializer(FormatIndicatedCacheSerializer.png)]) { [weak self] response in

                switch response {
                case .success(_):
                    self?.posterImageView.hideSkeleton()
                case .failure(let error):
                    if !error.isTaskCancelled && !error.isNotCurrentTask {
                        self?.posterImageView.hideSkeleton()
                        self?.posterImageView.image = UIImage(named: "placeholder")
                    }
                }
            }
        } else {
            posterImageView.hideSkeleton()
            posterImageView.image = UIImage(named: "placeholder")
        }
    }

}
