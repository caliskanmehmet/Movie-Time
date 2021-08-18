//
//  DetailViewController.swift
//  MovieTime
//
//  Created by obss on 2.08.2021.

import UIKit
import SafariServices
import Kingfisher

class DetailViewController: UIViewController {
    @IBOutlet weak var mainScrollView: UIScrollView! {
        didSet {
            mainScrollView.delegate = self
        }
    }

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
    @IBOutlet weak var topStackView: UIStackView!

    @IBOutlet weak var visitButton: UIButton!

    @IBOutlet weak var overviewTextView: UITextView!
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

    let genreCellId = "GenreCollectionViewCell"
    let companyCellId = "CompanyCollectionViewCell"

    var movieId: Int?
    var movie: Movie?
    var movieTitle: String?
    var favoriteMovies: [FavoriteMovie] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(moviesChanged),
                                               name: .moviesChanged,
                                               object: nil)

        favoriteMovies = FavoriteMovieManager.shared.favoriteMovies
        addFavoriteButton(with: movieId)

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
            addFavoriteButton(with: safeMovie.id)
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

        if safeMovie.homepage != nil && safeMovie.homepage != "" {
            visitButton.isEnabled = true
        }

        if safeMovie.genres?.count == 0 {
            genreCollectionView.setEmptyMessage(Constants.NO_GENRE)
        }

        if safeMovie.productionCompanies?.count == 0 {
            companyCollectionView.setEmptyMessage(Constants.NO_COMPANY)
        }

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

    private func addFavoriteButton(with movieId: Int?) {
        if let safeId = movieId {
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

                let viewController = SFSafariViewController(url: url, configuration: config)
                present(viewController, animated: true)
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

        if let overview = movie.overview {
            if overview != "" {
                overviewTextView.text = overview
            } else {
                overviewTextView.textAlignment = .center
                overviewTextView.font = UIFont.systemFont(ofSize: 20)
                overviewTextView.text = Constants.NO_OVERVIEW
            }
        }

        if let tagline = movie.tagline {
            if tagline != "" {
                overviewTextView.text.append("\n\n\"\(tagline)\"")
            }
        }
    }

    private func downloadAndSetImage(with urlString: String?, imageView: UIImageView) {
        let processor = DownsamplingImageProcessor(size: imageView.frame.size)
        imageView.setImage(urlString: urlString, processor: processor)
    }

    private func minutesToHoursMinutes(minutes: Int) -> (Int, Int) {
      return (minutes / 60, (minutes % 60))
    }

    private func showSkeletons() {
        posterImageView.showAnimatedSkeleton()
        backdropImageView.showAnimatedSkeleton()
        runtimeLabel.showAnimatedSkeleton()
        budgetLabel.showAnimatedSkeleton()
        titleLabel.showAnimatedSkeleton()
        releaseYearLabel.showAnimatedSkeleton()
        overviewTextView.showAnimatedSkeleton()
        dateLabel.showAnimatedSkeleton()
        ratingLabel.showAnimatedSkeleton()
        revenueLabel.showAnimatedSkeleton()
        genreCollectionView.showAnimatedSkeleton()
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

        alert.addAction(UIAlertAction(title: actionTitle, style: UIAlertAction.Style.default, handler: { (_) in
            alert.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }))

        self.present(alert, animated: true, completion: nil)
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
                let companies = movie?.productionCompanies

               // print(indexPath.row)
                let isLastCell = (indexPath.row + 1) == companies?.count
                safeCell.configure(with: companies?[indexPath.row], isLastCell: isLastCell)

                return safeCell
            } else {
                return UICollectionViewCell()
            }
        }
    }

}

// MARK: - UIScrollViewDelegate

extension DetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= topStackView.frame.height {
            self.title = movieTitle
        } else {
            self.title = nil
        }
    }
}
