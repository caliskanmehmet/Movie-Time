//
//  ViewController.swift
//  MovieTime
//
//  Created by obss on 30.07.2021.
//

import UIKit
import SkeletonView

class PopularViewController: UIViewController {
    let movieCellId = "MovieTableViewCell"
    let updateTimeInterval = 0.6
    var pageNumber = 1
    var filteredPageNumber = 1

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(UINib(nibName: movieCellId, bundle: nil), forCellReuseIdentifier: movieCellId)
        }
    }

    var searchController = UISearchController(searchResultsController: nil)

    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }

    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }

    var isResponseEmpty = false
    var query = ""
    var oldIndexPaths: [IndexPath]?
    var favoriteMovies: [FavoriteMovie] = []

    private var movies: [Movie] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    private var filteredMovies: [Movie] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(moviesChanged),
                                               name: .moviesChanged,
                                               object: nil)

        favoriteMovies = FavoriteMovieManager.shared.favoriteMovies

        getMoviesAndUpdate(pageNumber: pageNumber)
        initializeSearchController()
    }

    @objc private func moviesChanged(_ notification: Notification) {
        guard let items = notification.object as? [FavoriteMovie] else {
            let object = notification.object as Any
            assertionFailure("Invalid object: \(object)")
            return
        }

        favoriteMovies = items
        tableView.reloadData()
    }

    func initializeSearchController() {
        // Initialize search controller
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        self.definesPresentationContext = true
    }

    func getMoviesAndUpdate(pageNumber: Int) {
        tableView.tableFooterView = createSpinnerFooter()

        let urlRequest = APIRequest.getPopularMovies(pageNumber: pageNumber)

        NetworkManager.shared.fetchData(urlRequest: urlRequest, type: MovieResult.self) { [weak self] response in
            self?.tableView.tableFooterView = nil // Remove the spinner footer

            switch response {
            case .success(let result):
                if let movies = result.results {
                    self?.movies.append(contentsOf: movies)
                    self?.pageNumber += 1
                }
            case .failure(let error):
                self?.showAlertMessage(errorDescription: error.localizedDescription)
            }
        }
    }

    func searchMoviesAndUpdate(pageNumber: Int, query: String) {
        let child = SpinnerViewController()

        if filteredMovies.count == 0 {
            showSpinnerView(child: child)
        } else {
            tableView.tableFooterView = createSpinnerFooter()
        }

        let urlRequest = APIRequest.searchMovies(pageNumber: pageNumber, query: query)

        NetworkManager.shared.fetchData(urlRequest: urlRequest, type: MovieResult.self) { [weak self] response in
            if self?.filteredMovies.count == 0 {
                self?.hideSpinnerView(child: child)
            } else {
                self?.tableView.tableFooterView = nil // Remove the spinner footer
                self?.tableView.tableFooterView = UIView(frame: .zero) // Remove seperators for empty rows
            }

            switch response {
            case .success(let result):
                if let movies = result.results {
                    if movies.count > 0 {
                        self?.filteredMovies.append(contentsOf: movies)

                        self?.tableView.reloadDataThenPerform {
                            if pageNumber == 1 { // Only scroll to top when it is the first page
                                self?.scrollToTop()
                            }
                        }

                        self?.filteredPageNumber += 1
                    } else {
                        if movies.count == 0 && self?.filteredMovies.count == 0 {
                            let message = Constants.NO_MOVIE
                            self?.showAlertMessage(errorDescription: message)
                        }
                        self?.isResponseEmpty = true
                    }
                }
            case .failure(let error):
                self?.showAlertMessage(errorDescription: error.localizedDescription)
            }
        }
    }

    private func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))

        let spinner = UIActivityIndicatorView()
        spinner.style = .gray
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()

        return footerView
    }

    private func scrollToTop() {
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: false)
    }

    private func showAlertMessage(errorDescription: String) {
        let title = Constants.ERROR
        let actionTitle = Constants.OK

        let alert = UIAlertController(title: title, message: errorDescription, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: actionTitle, style: UIAlertAction.Style.default, handler: nil))

        // Avoid "is already presenting" and "present from detached VC" warning
        self.view.window?.rootViewController?.present(alert, animated: true, completion: nil)

    }

    private func showSpinnerView(child: SpinnerViewController) {
        self.addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    private func hideSpinnerView(child: SpinnerViewController) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }

    private func getFavoriteAction(indexPath: IndexPath) -> UIContextualAction {
        let title = Constants.FAVORITE

        let favoriteAction = UIContextualAction(style: .normal, title: title, handler: { (_: UIContextualAction, _: UIView, success: (Bool) -> Void) in
            // Call favorite action
            let movieArray = self.getMovieArray()

            let movie = movieArray[indexPath.row]
            if let safeId = movie.id {
                self.favoriteMovies.append(FavoriteMovie(id: safeId, posterPath: movie.getPosterPath()))
            } else {
                print("Error during ID fetching")
            }

            // Reset state
            success(true)

            Timer.scheduledTimer(withTimeInterval: self.updateTimeInterval, repeats: false) { _ in
                FavoriteMovieManager.shared.saveFavoriteMovies(movies: self.favoriteMovies)
            }

        })

        return favoriteAction
    }

    private func getUnfavoriteAction(indexPath: IndexPath) -> UIContextualAction {
        let title = Constants.UNFAVORITE

        let unfavoriteAction = UIContextualAction(style: .normal, title: title, handler: { (_: UIContextualAction, _: UIView, success: (Bool) -> Void) in
            // Call unfavorite action
            let movieArray = self.getMovieArray()

            if let safeId = movieArray[indexPath.row].id {
                if let index = self.favoriteMovies.firstIndex(where: {$0.id == safeId}) {
                    self.favoriteMovies.remove(at: index)
                }
            } else {
                print("Error during ID fetching")
            }

            // Reset state
            success(true)

            Timer.scheduledTimer(withTimeInterval: self.updateTimeInterval, repeats: false) { _ in
                FavoriteMovieManager.shared.saveFavoriteMovies(movies: self.favoriteMovies)
            }

        })

        return unfavoriteAction
    }

    private func getMovieArray() -> [Movie] {
        if isFiltering && filteredMovies.count > 0 {
            return filteredMovies
        } else {
            return movies
        }
    }

}

// MARK: - TableViewDataSource, TableViewDelegate

extension PopularViewController: SkeletonTableViewDataSource, SkeletonTableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let unsafeCell = tableView.dequeueReusableCell(withIdentifier: movieCellId, for: indexPath) as? MovieTableViewCell

        if let cell = unsafeCell {
            if isFiltering && filteredMovies.count > 0 {
                cell.configure(with: filteredMovies[indexPath.row], favorites: favoriteMovies)
            } else {
                cell.configure(with: movies[indexPath.row], favorites: favoriteMovies)
            }

            return cell
        } else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getMovieArray().count
    }

    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return movieCellId
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let detailVC = DetailViewController()
        detailVC.favoriteMovies = favoriteMovies

        detailVC.movieId = getMovieArray()[indexPath.row].id

        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 175.0
    }

    // Implement infinite scroll, maybe we can use tableview delegate methods
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (tableView.contentSize.height - scrollView.frame.size.height) {
             guard !NetworkManager.shared.isFetching else {
                return
             }

            if isFiltering && filteredMovies.count > 0 && !isResponseEmpty {
                searchMoviesAndUpdate(pageNumber: filteredPageNumber, query: query)
            } else if !isFiltering && movies.count > 0 {
                getMoviesAndUpdate(pageNumber: pageNumber)
            }

        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let favoriteAction = getFavoriteAction(indexPath: indexPath)
        let unfavoriteAction = getUnfavoriteAction(indexPath: indexPath)

        favoriteAction.image = UIImage(named: "heart.fill.white")
        favoriteAction.backgroundColor = .red

        unfavoriteAction.image = UIImage(named: "heart.slash")
        unfavoriteAction.backgroundColor = .gray

        let movieArray = getMovieArray()

        if let safeId = movieArray[indexPath.row].id {
            if favoriteMovies.contains(where: { movie in
                movie.id == safeId
            }) {
                return UISwipeActionsConfiguration(actions: [unfavoriteAction])
            } else {
                return UISwipeActionsConfiguration(actions: [favoriteAction])
            }
        }

        return UISwipeActionsConfiguration(actions: [])
    }

}

// MARK: - UISearchBarDelegate

extension PopularViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        isResponseEmpty = false

        if oldIndexPaths == nil {
            oldIndexPaths = tableView.indexPathsForVisibleRows // FIXED This causes problem for back to back searches --> RangeException
        }

        filteredPageNumber = 1

        query = searchBar.text!
        filteredMovies = []
        searchMoviesAndUpdate(pageNumber: filteredPageNumber, query: query)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isResponseEmpty = false
        filteredMovies = []
        searchBar.text = "" // This is necessary!!!

        tableView.reloadData()

        DispatchQueue.main.async {
            self.tableView.scrollToRow(at: self.oldIndexPaths?[0] ?? IndexPath(row: 0, section: 0), at: .top, animated: false)
            self.oldIndexPaths = nil
        }

    }

}
