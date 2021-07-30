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
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(UINib(nibName: movieCellId, bundle: nil), forCellReuseIdentifier: movieCellId)
        }
    }
    
    private var movies: [Movie] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        getMoviesAndUpdate(pageNumber: 5)
    }
    
    func getMoviesAndUpdate(pageNumber: Int) {
        MovieManager.shared.getPopularMovies(pageNumber: pageNumber) { [weak self] response in
            switch response {
                case .success(let result):
                    if let movies = result.results {
                        self?.movies = movies
                    }
                case .failure(let error):
                    print(error)
            }
        }
    }

}

extension PopularViewController: SkeletonTableViewDataSource, SkeletonTableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: movieCellId, for: indexPath) as! MovieTableViewCell
        cell.configure(with: movies[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
        
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return movieCellId
    }
    
}

//func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//    let cell = tableView.dequeueReusableCell(withIdentifier: movieCellId, for: indexPath) as! MovieTableViewCell
//    cell.configure(with: movies[indexPath.row])
//    return cell
//}
