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
    
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        
        if let releaseDate = movie.releaseDate {
            dateLabel.text = "Release Date: \(releaseDate)"
        } else {
            dateLabel.text = "Release Date: - "
        }
        
        
        if let rating = movie.voteAverage {
            ratingLabel.text = "\(String(format: "%.1f", rating)) / 10"
        } else {
            ratingLabel.text = " - / 10"
        }
        
        let processor = RoundCornerImageProcessor(cornerRadius: 30)
        posterImageView.showGradientSkeleton()
        posterImageView.kf.setImage(with: URL(string: movie.getPosterPath()), options: [.processor(processor)]) { result in
            self.posterImageView.hideSkeleton()
        }
        
        titleLabel.hideSkeleton()
        ratingLabel.hideSkeleton()
        dateLabel.hideSkeleton()
    }
    
}
