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
        // Initialization code

        titleLabel.showGradientSkeleton()
        ratingLabel.showGradientSkeleton()
        dateLabel.showGradientSkeleton()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(with movie: Movie, favorites: [Int]) {
        titleLabel.text = movie.title
        //self.posterImageView.image = UIImage(named: "placeholder")
        
        if let safeId = movie.id {
            if favorites.contains(safeId) {
                favoriteIcon.isHidden = false
            }
        }
        
        dateLabel.addLeading(image: UIImage(named: "calendar") ?? UIImage(), text: " \(movie.getReleaseDate())")
        ratingLabel.addLeading(image: UIImage(named: "star.fill") ?? UIImage(), text: " \(movie.getRating()) / 10")

        let processor = RoundCornerImageProcessor(cornerRadius: 30) |> DownsamplingImageProcessor(size: posterImageView.frame.size)
        posterImageView.showAnimatedSkeleton()

        if let safeUrl = movie.getPosterPath() {
            posterImageView.kf.setImage(with: URL(string: safeUrl), options: [.processor(processor),
                                                                              .scaleFactor(UIScreen.main.scale),
                                                                              .cacheOriginalImage]) { [weak self] response in

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

        titleLabel.hideSkeleton()
        ratingLabel.hideSkeleton()
        dateLabel.hideSkeleton()
    }
    
    override func prepareForReuse() {
        favoriteIcon.isHidden = true
    }

}
