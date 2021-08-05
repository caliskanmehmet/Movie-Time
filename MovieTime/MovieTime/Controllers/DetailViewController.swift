//
//  DetailViewController.swift
//  MovieTime
//
//  Created by obss on 2.08.2021.
//

import UIKit
import Kingfisher

class DetailViewController: UIViewController {
    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var overviewView: UIView!
    @IBOutlet weak var genreCollectionView: UICollectionView!
    
    var movie: Movie?
    var detailedMovie: Movie?
    let cellId = "GenreCollectionViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        MovieManager.shared.getMovieDetails(id: movie?.id ?? 0) { [weak self] response in
            switch response {
            case .success(let result):
                self?.detailedMovie = result
            case .failure(let error):
                print(error)
            }
        }
        
        initializeContent(with: movie)
        
        genreCollectionView.dataSource = self
        genreCollectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
        
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(favoriteTapped))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "heart"), style: .plain, target: self, action: #selector(favoriteTapped))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        genreCollectionView.flashScrollIndicators()
    }
    
    @objc func favoriteTapped() {
        print("favoriteTapped")
    }

    func initializeContent(with movie: Movie?) {
        guard let safeMovie = movie else { return }

        titleLabel.text = safeMovie.title
        overviewTextView.text = safeMovie.overview

        dateLabel.addLeading(image: UIImage(named: "calendar") ?? UIImage(), text: " \(safeMovie.getReleaseDate())")
        ratingLabel.addLeading(image: UIImage(named: "star.fill") ?? UIImage(), text: " \(safeMovie.getRating()) / 10 (\(movie?.voteCount ?? 0) votes)")

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
        
        overviewView.addSeparator(at: .bottom, color: .systemGray)
    }
}

extension DetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movie?.genreIds?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? GenreCollectionViewCell
        if let safeCell = cell {
            let originalGenreIds = GenreManager.shared.genres
            
            if let genre = originalGenreIds?.first(where: {$0.id == movie?.genreIds?[indexPath.row]}) {
                    safeCell.genreLabel.text = genre.name
            } else {
                    safeCell.genreLabel.text = ""
            }
            
            return safeCell
        } else {
            return UICollectionViewCell()
        }
    }
    
}
