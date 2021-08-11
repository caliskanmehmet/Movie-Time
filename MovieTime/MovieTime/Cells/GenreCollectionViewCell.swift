//
//  GenreCollectionViewCell.swift
//  MovieTime
//
//  Created by obss on 4.08.2021.
//

import UIKit

class GenreCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var genreLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        genreLabel.adjustsFontSizeToFitWidth = true

        self.layer.cornerRadius = 12
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1
        self.layer.masksToBounds = true

        switch traitCollection.userInterfaceStyle {
        case .light, .unspecified:
            self.layer.borderColor = UIColor.black.cgColor
        case .dark:
            self.layer.borderColor = UIColor.white.cgColor
        default:
            self.layer.borderColor = UIColor.black.cgColor
        }
    }

}
