//
//  CompanyCollectionViewCell.swift
//  MovieTime
//
//  Created by obss on 12.08.2021.
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

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        parentView.addSeparator(at: .right, color: .systemGray)
    }

    override func prepareForReuse() {
        posterImageView.image = nil
    }

    func configure(with company: ProductionCompany?) {
        if let safeCompany = company {
            titleLabel.text = safeCompany.name
            countryLabel.text = safeCompany.originCountry

            downloadAndSetPosterImage(with: safeCompany)
        }
    }

    func downloadAndSetPosterImage(with company: ProductionCompany) {
        posterImageView.showAnimatedSkeleton()

        let processor = DownsamplingImageProcessor(size: posterImageView.frame.size)

        if let safeUrl = company.getLogoPath() {
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

}
