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
        self.posterImageView.image = UIImage(named: "placeholder")
        
        if let releaseDate = movie.releaseDate {
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd"

            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "MMM dd, yyyy"
            
            var formattedDate = " - "
            
            if let date = dateFormatterGet.date(from: releaseDate) {
                formattedDate = dateFormatterPrint.string(from: date)
            }
            
            dateLabel.addLeading(image: UIImage(named: "calendar") ?? UIImage(), text: " \(formattedDate)")
        } else {
            dateLabel.addLeading(image: UIImage(named: "calendar") ?? UIImage(), text: " - ")
        }
        
        
        if let rating = movie.voteAverage {
            ratingLabel.addLeading(image: UIImage(named: "star.fill") ?? UIImage(), text: " \(String(format: "%.1f", rating)) / 10")
        } else {
            ratingLabel.addLeading(image: UIImage(named: "star.fill") ?? UIImage(), text: " - / 10")
        }
        
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
    
}
