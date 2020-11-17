//
//  FavoritsVC.swift
//  Podcasts
//
//  Created by Abdalah Omar on 11/2/20.
//  Copyright © 2020 Abdallah. All rights reserved.
//

import UIKit

class FavoritesCollectionView: UICollectionViewController ,UICollectionViewDelegateFlowLayout{

    
    var podcasts =  UserDefaults.standard.savedPodcasts()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
       configureCollection()
        
       gestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         podcasts =  UserDefaults.standard.savedPodcasts()
       collectionView.reloadData()
        UIApplication.mainTabaBarController()?.viewControllers?[1].tabBarItem.badgeValue = nil

    }
    fileprivate func configureCollection(){
        let nib = UINib(nibName:"FavoritesCell" , bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: Constant.favoriteCell)
        
    }
    
    fileprivate func gestureRecognizer() {
           let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
           collectionView.addGestureRecognizer(gesture)
       }
  //  var indexPath: IndexPath!
    @objc func handleLongPress(gesture:UILongPressGestureRecognizer){
        let location = gesture.location(in: collectionView)
        guard   let selectedIndexPath = collectionView.indexPathForItem(at: location) else{return}
        let selectedPodcast = self.podcasts[selectedIndexPath.item]

        //alret
        let alretController = UIAlertController(title: "Do you Need Remove   \(selectedPodcast.artistName ?? "")  Channel?", message: nil, preferredStyle: .actionSheet)
        alretController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
            //where we are removethe pdcast obj from collection
           

            self.podcasts.remove(at: selectedIndexPath.item)
            self.collectionView.deleteItems(at: [selectedIndexPath])
            UserDefaults.standard.deletPosdcast(podcast: selectedPodcast)
            self.collectionView.reloadData()
        }))

        alretController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alretController, animated: true)
    }
    
    
    //MARK: - collection
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return podcasts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.favoriteCell, for: indexPath) as! FavoritesCell
        cell.podcast = podcasts[indexPath.row]
      
        return cell
    }
  // constrain from cell of collection and  row
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // the width oh this var is the math calculate the screen now i needed 2 coulme in row ok  there is two coulme 16|coulme|16|coulme|16 the culculate of 3 * 16 ok
        let width = (view.frame.width - 3 * 16) / 2
        return CGSize(width: width, height: width + 55 )
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let episodeController = EpisodeTableView()
        episodeController.podcast = self.podcasts[indexPath.item]
        navigationController?.pushViewController(episodeController, animated: true)
    }
}

