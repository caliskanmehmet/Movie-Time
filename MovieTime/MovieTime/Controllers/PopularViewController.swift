//
//  ViewController.swift
//  MovieTime
//
//  Created by obss on 30.07.2021.
//
//  Add Sort button

import UIKit
import SkeletonView

class PopularViewController: UIViewController {
    let movieCellId = "MovieTableViewCell"
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
        return (searchController.isActive && !isSearchBarEmpty) || filteredMovies.count > 0
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
        // Do any additional setup after loading the view.
        if let data = UserDefaults.standard.value(forKey: "favorites") as? Data {
            favoriteMovies = (try? PropertyListDecoder().decode(Array<FavoriteMovie>.self, from: data)) ?? []
        }

        getMoviesAndUpdate(pageNumber: pageNumber)
        initializeSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let data = UserDefaults.standard.value(forKey: "favorites") as? Data {
            favoriteMovies = (try? PropertyListDecoder().decode(Array<FavoriteMovie>.self, from: data)) ?? []
        }
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

        MovieManager.shared.getPopularMovies(pageNumber: pageNumber) { [weak self] response in
            self?.tableView.tableFooterView = nil // Remove the spinner footer

            switch response {
            case .success(let result):
                if let movies = result.results {
                    self?.movies.append(contentsOf: movies)
                    print("Fetched page \(pageNumber)")
                    self?.pageNumber += 1
                }
            case .failure(let error):
                let alert = UIAlertController(title: "Error", message: error.localizedDescription.description, preferredStyle: UIAlertController.Style.alert)

                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                self?.present(alert, animated: true, completion: nil)
            }
        }
    }

    func searchMoviesAndUpdate(pageNumber: Int, query: String) {
        let child = SpinnerViewController()

        if filteredMovies.count == 0 {
            self.addChild(child)
            child.view.frame = view.frame
            view.addSubview(child.view)
            child.didMove(toParent: self)
        } else {
            tableView.tableFooterView = createSpinnerFooter()
        }

        MovieManager.shared.searchMovies(pageNumber: pageNumber, query: query) { [weak self] response in
            if self?.filteredMovies.count == 0 {
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                child.removeFromParent()
            } else {
                self?.tableView.tableFooterView = nil // Remove the spinner footer
            }

            switch response {
            case .success(let result):
                if let movies = result.results {
                    if movies.count > 0 {
                        self?.filteredMovies.append(contentsOf: movies)
                        print("Fetched page \(pageNumber)")

                        self?.tableView.reloadData {
                            if pageNumber == 1 { // Only scroll to top when it is the first page
                                self?.scrollToTop()
                            }
                        }

                        self?.filteredPageNumber += 1
                    } else if movies.count == 0 && self?.filteredMovies.count == 0 {
                        let alert = UIAlertController(title: "Error", message: "No movie available!", preferredStyle: UIAlertController.Style.alert)

                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))

                        self?.present(alert, animated: true, completion: nil)
                        self?.isResponseEmpty = true
                    } else {
                        self?.isResponseEmpty = true
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    private func createSpinnerFooter() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))

        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()

        return footerView
    }

    private func scrollToTop() {
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: false)
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
        if isFiltering {
            return filteredMovies.count
        } else {
            return movies.count
        }
    }

    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return movieCellId
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let detailVC = DetailViewController()
        detailVC.favoriteMovies = favoriteMovies

        if isFiltering {
            detailVC.movieId = filteredMovies[indexPath.row].id
        } else {
            detailVC.movieId = movies[indexPath.row].id
        }

        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(detailVC, animated: true)
    }

    // Implement infinite scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (tableView.contentSize.height - scrollView.frame.size.height) {
            guard !MovieManager.shared.isFetching else {
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

        if isFiltering {
            if let safeId = filteredMovies[indexPath.row].id {
                if favoriteMovies.contains(where: { movie in
                    movie.id == safeId
                }) {
                    return UISwipeActionsConfiguration(actions: [unfavoriteAction])
                } else {
                    return UISwipeActionsConfiguration(actions: [favoriteAction])
                }
            }
        } else {
            if let safeId = movies[indexPath.row].id {
                if favoriteMovies.contains(where: { movie in
                    movie.id == safeId
                }) {
                    return UISwipeActionsConfiguration(actions: [unfavoriteAction])
                } else {
                    return UISwipeActionsConfiguration(actions: [favoriteAction])
                }
            }
        }

        return UISwipeActionsConfiguration(actions: [])
    }

    private func getFavoriteAction(indexPath: IndexPath) -> UIContextualAction {
        let favoriteAction = UIContextualAction(style: .normal, title: "Favorite", handler: { (_: UIContextualAction, _: UIView, success: (Bool) -> Void) in
            // Call favorite action
            if self.isFiltering {
                let movie = self.filteredMovies[indexPath.row]
                if let safeId = movie.id {
                    self.favoriteMovies.append(FavoriteMovie(id: safeId, posterPath: movie.getPosterPath()))
                } else {
                    print("Error during ID fetching")
                }
            } else {
                let movie = self.movies[indexPath.row]
                if let safeId = movie.id {
                    self.favoriteMovies.append(FavoriteMovie(id: safeId, posterPath: movie.getPosterPath()))
                } else {
                    print("Error during ID fetching")
                }
            }

            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.favoriteMovies), forKey: "favorites")

            // Reset state
            success(true)

            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
                // tableView.reloadRows(at: [indexPath], with: .automatic)
                self.tableView.reloadData()
            }

        })

        return favoriteAction
    }

    private func getUnfavoriteAction(indexPath: IndexPath) -> UIContextualAction {
        let unfavoriteAction = UIContextualAction(style: .normal, title: "Unfavorite", handler: { (_: UIContextualAction, _: UIView, success: (Bool) -> Void) in
            // Call unfavorite action
            if self.isFiltering {
                if let safeId = self.filteredMovies[indexPath.row].id {
                    if let index = self.favoriteMovies.firstIndex(where: {$0.id == safeId}) {
                        self.favoriteMovies.remove(at: index)
                    }
                } else {
                    print("Error during ID fetching")
                }
            } else {
                if let safeId = self.movies[indexPath.row].id {
                    if let index = self.favoriteMovies.firstIndex(where: {$0.id == safeId}) {
                        self.favoriteMovies.remove(at: index)
                    }
                } else {
                    print("Error during ID fetching")
                }
            }

            UserDefaults.standard.set(try? PropertyListEncoder().encode(self.favoriteMovies), forKey: "favorites")

            // Reset state
            success(true)

            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
                // tableView.reloadRows(at: [indexPath], with: .automatic)
                self.tableView.reloadData()
            }

        })

        return unfavoriteAction
    }

}

// MARK: - UISearchResultsUpdating

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
