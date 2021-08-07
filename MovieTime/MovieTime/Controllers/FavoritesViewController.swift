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
            favoriteCollectionView.register(FavoriteCollectionViewCell.self, forCellWithReuseIdentifier: cellId)
        }
    }
    
    let cellId = "FavoriteCollectionViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        print("Favorites")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }

}

//MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension FavoritesViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
        return cell
    }
    
    
}
