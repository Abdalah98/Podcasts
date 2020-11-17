//
//  EpisodeTableView.swift
//  Podcasts
//
//  Created by Abdalah Omar on 11/4/20.
//  Copyright © 2020 Abdallah. All rights reserved.
//

import UIKit
import FeedKit

class EpisodeTableView: UITableViewController {
    
    var userDefault = UserDefaults.standard
    var episodes = [Episode]()

    @IBOutlet weak var fetchBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var favoriteBarButtonItem : UIBarButtonItem!
    var podcast:Results?{
        didSet{
            navigationItem.title = podcast?.trackName
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    

        configureTableView()
        fetchEpisode()
       setupfNavigationeBarButtonItem()
    }
    
    fileprivate func fetchEpisode(){
        
        guard  let feedURL = podcast?.feedUrl else{return}
        NetworkManger.shared.fetchEpisode(feedURL: feedURL) { (episode) in
            self.episodes = episode
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }
    
    
    fileprivate func configureTableView(){
        tableView.tableFooterView = UIView()
        let nib = UINib(nibName: Constant.episodeCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Constant.episodeDatacell)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.color = .darkGray
        activityIndicatorView.startAnimating()
        return activityIndicatorView
        
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return episodes.isEmpty ? 200 :0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.episodeDatacell, for: indexPath) as! EpisodeCell
        let episode = episodes[indexPath.row]
        cell.episode = episode
        return cell
    }
    
    
    
    
    override  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = episodes[indexPath.row]
        let mainTabaBarController = UIApplication.mainTabaBarController()
        mainTabaBarController?.maximizedPlayerDetails(episode: episode,playListEpisode:self.episodes)
        
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let DownloadAction = UIContextualAction(style: .normal, title: "Download") {  (_, _, _) in
            let episode = self.episodes[indexPath.row]
            self.userDefault.downlaodEpisode(episode: episode)
            
            //downlaod the podcast episode using almofire
            NetworkManger.shared.downloadEpisode(episode: episode)
            self.showBadgeHightLightOfDownlaods() 
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [DownloadAction])

        return swipeActions
    }
    
    
    override  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    fileprivate func setupfNavigationeBarButtonItem(){
        //lets check if we have already save the podcast
        let savedPodcasts = UserDefaults.standard.savedPodcasts()
        let havFavorited  = savedPodcasts.firstIndex(where: { $0.trackName == self.podcast?.trackName && $0.artistName == self.podcast?.artistName}) != nil
        if havFavorited {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "star.fill"), style: .plain, target: nil, action: nil)
        }else{
      
                navigationItem.rightBarButtonItem = favoriteBarButtonItem
        }
    }
    
    
    //MARK: - IBAction
    @IBAction func favoriteButtonAction(_ sender: Any) {
        
        guard let podcasts = podcast else{return}
        
        //fetch our saved pdcasts first y2ne kol m3mal save btappent in arry it the extion
        
        // transform Podcast into data
        var listOfPodcasts = userDefault.savedPodcasts()
        listOfPodcasts.append(podcasts)
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject:listOfPodcasts,requiringSecureCoding:false)
            userDefault.set(data, forKey: Constant.favoritedPodcastKey )
             showBadgeHightLight()
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "star.fill"), style: .plain, target: nil, action: nil)
        } catch let error{
            print(error)
        }
    }
    
    @IBAction func fetchButtonAction(_ sender: Any) {
        
        guard  let data = userDefault.data(forKey: Constant.favoritedPodcastKey
            ) else{return}
        do {
            
            let loadedStrings = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Results]
            loadedStrings?.forEach({ (p) in
                print(p.artistName ?? "" ,p.artworkUrl100 ?? "",p.trackName ?? "" )
                
            })
            
        } catch {
            print("Couldn't read file.")
        }
    }
 fileprivate   func showBadgeHightLight(){
    UIApplication.mainTabaBarController()?.viewControllers?[1].tabBarItem.badgeValue = "New"
    

    
    }
    fileprivate   func showBadgeHightLightOfDownlaods(){
  
        UIApplication.mainTabaBarController()?.viewControllers?[2].tabBarItem.badgeValue = "New"

    
    }
}
