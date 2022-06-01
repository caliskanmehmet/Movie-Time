//
//  CompanyCollectionViewCell.swift
//  MovieTime
//
//  Created by Mehmet Caliskan on 12.08.2021.
//

import UIKit
import Kingfisher

class CompanyCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.adjustsFontSizeToFitWidth = true
        }
    }
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var countryLabel: UILabel!

    var seperator: UIView?

    override func prepareForReuse() {
        removeSeperator()
        posterImageView.image = nil
    }

    func configure(with company: ProductionCompany?, isLastCell: Bool) {
        if !isLastCell {
            seperator = parentView.addSeparator(at: .right, color: .systemGray)
        }

        if let safeCompany = company {
            titleLabel.text = safeCompany.name
            countryLabel.text = safeCompany.originCountry

            downloadAndSetPosterImage(with: safeCompany)
        }
    }

    func downloadAndSetPosterImage(with company: ProductionCompany) {
        let processor = DownsamplingImageProcessor(size: posterImageView.frame.size)
        posterImageView.setImage(urlString: company.getLogoPath(), processor: processor)
    }

    func removeSeperator() {
        if let seperatorView = seperator {
            seperatorView.removeFromSuperview()
        }
    }

}
