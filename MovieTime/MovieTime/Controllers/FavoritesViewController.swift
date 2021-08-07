//
//  FavoritesViewController.swift
//  MovieTime
//
//  Created by obss on 30.07.2021.
//

import UIKit

class FavoritesViewController: UIViewController {
    @IBOutlet weak var favoriteCollectionView: UICollectionView! {
        didSet {
            favoriteCollectionView.dataSource = self
            favoriteCollectionView.delegate = self
        }
    }
    
    let cellId = "FavoriteCollectionViewCell"
    var favoriteMovies: [FavoriteMovie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let data = UserDefaults.standard.value(forKey:"favorites") as? Data {
            favoriteMovies = (try? PropertyListDecoder().decode(Array<FavoriteMovie>.self, from: data)) ?? []
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("viewWillAppear!!!")
        
        if let data = UserDefaults.standard.value(forKey:"favorites") as? Data {
            favoriteMovies = (try? PropertyListDecoder().decode(Array<FavoriteMovie>.self, from: data)) ?? []
        }
        
        favoriteCollectionView.reloadData()
    }

}

//MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension FavoritesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoriteMovies.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? FavoriteCollectionViewCell
        if let safeCell = cell {
            safeCell.configure(with: favoriteMovies[indexPath.row])
            
            return safeCell
        }
        return UICollectionViewCell()
    }
    
    
}
