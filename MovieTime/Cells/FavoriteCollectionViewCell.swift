//
//  FavoriteCollectionViewCell.swift
//  MovieTime
//
//  Created by Mehmet Caliskan on 7.08.2021.
//

import UIKit
import Kingfisher

class FavoriteCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var posterImageView: UIImageView!

    func configure(with movie: FavoriteMovie) {
        let processor = RoundCornerImageProcessor(cornerRadius: 20) |> DownsamplingImageProcessor(size: posterImageView.frame.size)
        posterImageView.setImage(urlString: movie.posterPath, processor: processor)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
    }

}
