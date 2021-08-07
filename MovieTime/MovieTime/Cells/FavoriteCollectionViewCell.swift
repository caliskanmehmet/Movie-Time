//
//  FavoriteCollectionViewCell.swift
//  MovieTime
//
//  Created by obss on 7.08.2021.
//

import UIKit
import Kingfisher

class FavoriteCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    
    func configure(with movie: FavoriteMovie) {
        posterImageView.showAnimatedSkeleton()
        
        let processor = RoundCornerImageProcessor(cornerRadius: 30) |> DownsamplingImageProcessor(size: posterImageView.frame.size)

        if let safeUrl = movie.posterPath {
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
    }
    
    override func prepareForReuse() {
        posterImageView.showGradientSkeleton()
    }
    
}
