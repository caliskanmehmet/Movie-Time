//
//  DetailViewController.swift
//  MovieTime
//
//  Created by obss on 2.08.2021.
//

import UIKit
import SafariServices
import Kingfisher

class DetailViewController: UIViewController {
    @IBOutlet weak var mainScrollView: UIScrollView!

    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var posterImageView: UIImageView!

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var releaseYearLabel: UILabel! {
        didSet {
            releaseYearLabel.adjustsFontSizeToFitWidth = true
        }
    }
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel! {
        didSet {
            ratingLabel.adjustsFontSizeToFitWidth = true
        }
    }
    @IBOutlet weak var runtimeLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var revenueLabel: UILabel!

    @IBOutlet weak var overviewView: UIView!
    @IBOutlet weak var basicInfoView: UIView!
    @IBOutlet weak var genreView: UIView!
    @IBOutlet weak var companyView: UIView!
    @IBOutlet weak var websiteView: UIView!

    @IBOutlet weak var visitButton: UIButton!

    @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var genreCollectionView: UICollectionView! {
        didSet {
            genreCollectionView.dataSource = self
            genreCollectionView.register(UINib(nibName: genreCellId, bundle: nil), forCellWithReuseIdentifier: genreCellId)
        }
    }
    @IBOutlet weak var companyCollectionView: UICollectionView! {
        didSet {
            companyCollectionView.dataSource = self
            companyCollectionView.register(UINib(nibName: companyCellId, bundle: nil), forCellWithReuseIdentifier: companyCellId)
        }
    }

    var movieId: Int?
    var movie: Movie?
    var favoriteMovies: [FavoriteMovie] = []
    let genreCellId = "GenreCollectionViewCell"
    let companyCellId = "CompanyCollectionViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(moviesChanged),
                                               name: .moviesChanged,
                                               object: nil)

        favoriteMovies = FavoriteMovieManager.shared.favoriteMovies

        fetchMovieDetails()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        mainScrollView.flashScrollIndicators()
        genreCollectionView.flashScrollIndicators()
    }

    @objc private func moviesChanged(_ notification: Notification) {
        guard let items = notification.object as? [FavoriteMovie] else {
            let object = notification.object as Any
            assertionFailure("Invalid object: \(object)")
            return
        }

        favoriteMovies = items

        if let safeMovie = movie {
            addFavoriteButton(with: safeMovie)
        }
    }

    private func fetchMovieDetails() {
        showSkeletons()

        let urlRequest = APIRequest.getMovieDetails(movieId: movieId ?? 0)

        NetworkManager.shared.fetchData(urlRequest: urlRequest, type: Movie.self) { [weak self] response in
            switch response {
            case .success(let result):
                self?.movie = result
                self?.initializeContent()
                self?.hideSkeletons()
            case .failure(let error):
                self?.showAlertMessage(error: error)
            }
        }
    }

    func initializeContent() {
        guard let safeMovie = movie else { return }

        if safeMovie.homepage == nil || safeMovie.homepage == "" {
            visitButton.isEnabled = false
        }

        addFavoriteButton(with: safeMovie)
        setLabelTexts(with: safeMovie)

        downloadAndSetImage(with: safeMovie.getPosterPath(), imageView: posterImageView)
        downloadAndSetImage(with: safeMovie.getBackdropPath(), imageView: backdropImageView)

        overviewView.addSeparator(at: .bottom, color: .systemGray)
        overviewView.addSeparator(at: .top, color: .systemGray)
        companyView.addSeparator(at: .top, color: .systemGray)
        websiteView.addSeparator(at: .top, color: .systemGray)

        genreCollectionView.reloadData()
        companyCollectionView.reloadData()
    }

    private func addFavoriteButton(with movie: Movie) {
        if let safeId = movie.id {
            if favoriteMovies.contains(where: { movie in
                movie.id == safeId
            }) {
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "heart.slash"), style: .plain, target: self, action: #selector(favoriteTapped))
            } else {
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "heart.outlined"), style: .plain, target: self, action: #selector(favoriteTapped))
            }
        }
    }

    @objc func favoriteTapped() {
        if let safeId = movieId {
            if favoriteMovies.contains(where: { movie in
                movie.id == safeId
            }) {
                // Unfavorite the film

                navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "heart.outlined"), style: .plain, target: self, action: #selector(favoriteTapped))

                if let index = favoriteMovies.firstIndex(where: {$0.id == safeId}) {
                    self.favoriteMovies.remove(at: index)
                }
            } else {
                // Favorite the film

                navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "heart.slash"), style: .plain, target: self, action: #selector(favoriteTapped))
                favoriteMovies.append(FavoriteMovie(id: safeId, posterPath: movie?.getPosterPath()))
            }

            FavoriteMovieManager.shared.saveFavoriteMovies(movies: favoriteMovies)
        }
    }

    @IBAction func visitButtonTapped(_ sender: Any) {
        if let homepage = movie?.homepage {
            if let url = URL(string: homepage) {
                let config = SFSafariViewController.Configuration()
                config.entersReaderIfAvailable = true

                let vc = SFSafariViewController(url: url, configuration: config)
                present(vc, animated: true)
            }
        }
    }

    private func setLabelTexts(with movie: Movie) {
        var runtimeString = " - "

        if let runtime = movie.runtime {
            if runtime != 0 {
                let runtimeTuple = minutesToHoursMinutes(minutes: runtime)
                runtimeString = String(format: Constants.MOVIE_DURATION, runtimeTuple.0, runtimeTuple.1)
            }
        }

        let budgetString = movie.getBudget()
        let voteString = String(format: Constants.VOTES, movie.getVoteCount())

        dateLabel.addLeading(image: UIImage(named: "calendar") ?? UIImage(), text: " \(movie.getReleaseDate())")
        ratingLabel.text = "􀋃  \(movie.getRating()) (\(voteString))"
        runtimeLabel.text = "􀐫  \(runtimeString)"
        budgetLabel.text = "􀖗  \(budgetString)"
        revenueLabel.addLeading(image: UIImage(named: "revenue")!, text: "   \(movie.getRevenue())", offset: -2.0)

        titleLabel.text = movie.title
        releaseYearLabel.text = "\(movie.originalTitle ?? " - ") • \(movie.releaseDate?[0..<4] ?? " - ") • \(movie.originalLanguage ?? " - ")"
        overviewTextView.text = movie.overview ?? " - "
    }

    private func downloadAndSetImage(with urlString: String?, imageView: UIImageView) {

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

    private func minutesToHoursMinutes(minutes: Int) -> (Int, Int) {
      return (minutes / 60, (minutes % 60))
    }

    private func showSkeletons() {
        posterImageView.showGradientSkeleton()
        backdropImageView.showGradientSkeleton()
        runtimeLabel.showGradientSkeleton()
        budgetLabel.showGradientSkeleton()
        titleLabel.showGradientSkeleton()
        releaseYearLabel.showGradientSkeleton()
        overviewTextView.showGradientSkeleton()
        dateLabel.showGradientSkeleton()
        ratingLabel.showGradientSkeleton()
        revenueLabel.showGradientSkeleton()
        genreCollectionView.showGradientSkeleton()
    }

    private func hideSkeletons() {
        runtimeLabel.hideSkeleton()
        budgetLabel.hideSkeleton()
        titleLabel.hideSkeleton()
        releaseYearLabel.hideSkeleton()
        overviewTextView.hideSkeleton()
        dateLabel.hideSkeleton()
        ratingLabel.hideSkeleton()
        revenueLabel.hideSkeleton()
        genreCollectionView.hideSkeleton()
    }

    private func showAlertMessage(error: Error) {
        let title = Constants.ERROR
        let actionTitle = Constants.OK

        let alert = UIAlertController(title: title, message: error.localizedDescription.description, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: actionTitle, style: UIAlertAction.Style.default, handler: nil))

        present(alert, animated: true, completion: nil)
    }

}

// MARK: - UICollectionViewDataSource

extension DetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if collectionView == genreCollectionView {
            return movie?.genres?.count ?? 0
        } else {
            return movie?.productionCompanies?.count ?? 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == genreCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: genreCellId, for: indexPath) as? GenreCollectionViewCell

            if let safeCell = cell {
                safeCell.genreLabel.text = movie?.genres?[indexPath.row].name
                return safeCell
            } else {
                return UICollectionViewCell()
            }
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: companyCellId, for: indexPath) as? CompanyCollectionViewCell

            if let safeCell = cell {
                safeCell.configure(with: movie?.productionCompanies?[indexPath.row])
                return safeCell
            } else {
                return UICollectionViewCell()
            }
        }
    }

}
