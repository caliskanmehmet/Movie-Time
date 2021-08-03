//
//  DetailViewController.swift
//  MovieTime
//
//  Created by obss on 2.08.2021.
//

import UIKit
import Kingfisher

class DetailViewController: UIViewController {
    var movie: Movie?
    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initializeContent(with: movie)
    }

    func initializeContent(with movie: Movie?) {
        guard let safeMovie = movie else { return }

        titleLabel.text = safeMovie.title
        overviewTextView.text = safeMovie.overview

        dateLabel.addLeading(image: UIImage(named: "calendar") ?? UIImage(), text: " \(safeMovie.getReleaseDate())")
        ratingLabel.addLeading(image: UIImage(named: "star.fill") ?? UIImage(), text: " \(safeMovie.getRating()) / 10")

        var processor = DownsamplingImageProcessor(size: posterImageView.frame.size)

        posterImageView.showAnimatedSkeleton()
        if let safeUrl = safeMovie.getPosterPath() {
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

        processor = DownsamplingImageProcessor(size: backdropImageView.frame.size)
        backdropImageView.showAnimatedSkeleton()
        if let safeUrl = safeMovie.getBackdropPath() {
            backdropImageView.kf.setImage(with: URL(string: safeUrl), options: [.processor(processor),
                                                                              .scaleFactor(UIScreen.main.scale),
                                                                              .cacheOriginalImage]) { [weak self] response in

                switch response {
                case .success(_):
                    self?.backdropImageView.hideSkeleton()
                case .failure(let error):
                    if !error.isTaskCancelled && !error.isNotCurrentTask {
                        self?.backdropImageView.hideSkeleton()
                        self?.backdropImageView.image = UIImage(named: "placeholder")
                    }
                }
            }
        } else {
            backdropImageView.hideSkeleton()
            backdropImageView.image = UIImage(named: "placeholder")
        }
    }
}
