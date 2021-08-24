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

        genreLabel.adjustsFontSizeToFitWidth = true

        self.layer.cornerRadius = 12
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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.userInterfaceStyle == .dark {
            self.layer.borderColor = UIColor.white.cgColor
        } else {
            self.layer.borderColor = UIColor.black.cgColor
        }
    }

}
