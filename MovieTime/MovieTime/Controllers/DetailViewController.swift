//
//  DetailViewController.swift
//  MovieTime
//
//  Created by obss on 2.08.2021.
//

import UIKit
import Kingfisher

class DetailViewController: UIViewController {
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseYearLabel: UILabel!
    @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var overviewView: UIView!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var basicInfoView: UIView!
    @IBOutlet weak var genreCollectionView: UICollectionView! {
        didSet {
            genreCollectionView.dataSource = self
            genreCollectionView.register(UINib(nibName: cellId, bundle: nil), forCellWithReuseIdentifier: cellId)
        }
    }
    @IBOutlet weak var genreView: UIView!
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    
    var movie: Movie?
    var favoriteMovies: [FavoriteMovie]?
    let cellId = "GenreCollectionViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchMovieDetails()
        initializeContent(with: movie)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        mainScrollView.flashScrollIndicators()
        genreCollectionView.flashScrollIndicators()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(self.favoriteMovies), forKey:"favorites")
    }
    
    private func fetchMovieDetails() {
        runtimeLabel.showGradientSkeleton()
        budgetLabel.showGradientSkeleton()
        
        MovieManager.shared.getMovieDetails(id: movie?.id ?? 0) { [weak self] response in
            switch response {
            case .success(let result):
                let runtimeTuple = self?.minutesToHoursMinutes(minutes: result.runtime ?? 0)
                let runtimeString = "\(runtimeTuple?.0 ?? 0)h \(runtimeTuple?.1 ?? 0)m"
                let budgetString = NumberFormatter.localizedString(from: NSNumber(value: result.budget ?? 0), number: NumberFormatter.Style.decimal)
                
                self?.runtimeLabel.addLeading(image: UIImage(named: "clock") ?? UIImage(), text: " \(runtimeString) ")
                self?.budgetLabel.addLeading(image: UIImage(named: "dollar") ?? UIImage(), text: " \(budgetString) $")
                
                self?.runtimeLabel.hideSkeleton()
                self?.budgetLabel.hideSkeleton()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func initializeContent(with movie: Movie?) {
        guard let safeMovie = movie else { return }
        
        addFavoriteButton(with: safeMovie)
        setLabelTexts(with: safeMovie)
        
        downloadAndSetImage(with: safeMovie.getPosterPath(), imageView: posterImageView)
        downloadAndSetImage(with: safeMovie.getBackdropPath(), imageView: backdropImageView)

        overviewView.addSeparator(at: .bottom, color: .systemGray)
        overviewView.addSeparator(at: .top, color: .systemGray)
    }
    
    private func addFavoriteButton(with movie: Movie) {
        if let safeFavMovies = favoriteMovies, let safeId = movie.id {
            if safeFavMovies.contains(where: { movie in
                movie.id == safeId
            }) {
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "heart.slash"), style: .plain, target: self, action: #selector(favoriteTapped))
            } else {
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "heart"), style: .plain, target: self, action: #selector(favoriteTapped))
            }
        }
    }
    
    private func setLabelTexts(with movie: Movie) {
        titleLabel.text = movie.title
        releaseYearLabel.adjustsFontSizeToFitWidth = true
        releaseYearLabel.text = "\(movie.originalTitle ?? " - ") • \(movie.releaseDate?[0..<4] ?? " - ") • \(movie.originalLanguage ?? " - ")"
        overviewTextView.text = movie.overview
        dateLabel.addLeading(image: UIImage(named: "calendar") ?? UIImage(), text: " \(movie.getReleaseDate())")
        ratingLabel.addLeading(image: UIImage(named: "star.fill") ?? UIImage(), text: " \(movie.getRating()) / 10 (\(movie.voteCount ?? 0) votes)")
    }
    
    private func downloadAndSetImage(with urlString: String?, imageView: UIImageView) {
        imageView.showAnimatedSkeleton()
        
        let processor = DownsamplingImageProcessor(size: imageView.frame.size)
        
        if let safeUrl = urlString {
            imageView.kf.setImage(with: URL(string: safeUrl), options: [.processor(processor),
                                                                              .scaleFactor(UIScreen.main.scale),
                                                                              .cacheOriginalImage]) { response in

                switch response {
                case .success(_):
                    imageView.hideSkeleton()
                case .failure(let error):
                    if !error.isTaskCancelled && !error.isNotCurrentTask {
                        imageView.hideSkeleton()
                        imageView.image = UIImage(named: "placeholder")
                    }
                }
            }
        } else {
            imageView.hideSkeleton()
            imageView.image = UIImage(named: "placeholder")
        }
    }
    
    @objc func favoriteTapped() {
        guard let safeMovie = movie else { return }
        
        if let safeFavMovies = favoriteMovies, let safeId = safeMovie.id {
            if safeFavMovies.contains(where: { movie in
                movie.id == safeId
            }) {
                // Unfavorite the film
                
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "heart"), style: .plain, target: self, action: #selector(favoriteTapped))
                
                if let index = safeFavMovies.firstIndex(where: {$0.id == safeId}) {
                    self.favoriteMovies?.remove(at: index)
                }
            } else {
                // Favorite the film
                
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "heart.slash"), style: .plain, target: self, action: #selector(favoriteTapped))
                favoriteMovies?.append(FavoriteMovie(id: safeId, posterPath: safeMovie.getPosterPath()))
            }
        }
    }
    
    private func minutesToHoursMinutes(minutes : Int) -> (Int, Int) {
      return (minutes / 60, (minutes % 60))
    }

}

// MARK: - UICollectionViewDataSource

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
