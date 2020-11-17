//
//  SearchVC.swift
//  Podcasts
//
//  Created by Abdalah Omar on 11/2/20.
//  Copyright © 2020 Abdallah. All rights reserved.
//

import UIKit
import Alamofire
class SearchVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var podcastes       = [Results]()
    var timer : Timer?
    let searchController = UISearchController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         searchController.searchBar.placeholder = "Search Here"
        navigationController?.navigationBar.prefersLargeTitles = true
        configureSearch()
        configureTableView()
      // searchBar(searchController.searchBar, textDidChange: "Voong")//Waveform
           //Apple Events
       //Lahtha
           //Rumooz
           //Mics
            //SeanAllen
           

        activityIndicator.hidesWhenStopped = true
    }
    
    
    
    fileprivate func configureSearch() {
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
    }
    
    fileprivate func configureTableView(){
        tableView.tableFooterView = UIView()
        let nib = UINib(nibName: Constant.podcastCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Constant.searchCell)
    }
}


//MARK: - SearchTableView

extension SearchVC:UITableViewDelegate,UITableViewDataSource{
    //Header
 
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label                  = UILabel()
        label.text                 = "Search the largest library of the podcast by the title of the artist's name."
        label.numberOfLines        = 2
        label.textColor            = .systemPurple
        label.textAlignment        = .center
        label.font                 = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.podcastes.count > 0 ? 0 : 250
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcastes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.searchCell, for: indexPath)as! PodcastCell
        let podcast = podcastes[indexPath.row]
        cell.podcast = podcast
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 132
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
      performSegue(withIdentifier: Constant.selectIndexData, sender: self)

    }
    
    //MARK: - prepareSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
                if segue.identifier == Constant.selectIndexData {
                    let episodeController = segue.destination as! EpisodeTableView


                    if let indexPath = tableView.indexPathForSelectedRow {
                        episodeController.podcast = podcastes[indexPath.row]
                    }else{
                      return print("error")
                  }
                }
            }
    
    
    //MARK: - IBoult
}



//MARK: - SearchController
//Brianvoong
extension SearchVC :UISearchBarDelegate, UISearchControllerDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.activityIndicator.startAnimating()

        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { (time) in

              NetworkManger.shared.fetchPhotoPodcasts(searchText: searchText) { (podcasts) in
                      self.podcastes = podcasts
                      self.tableView.reloadData()

                  }
            self.activityIndicator.stopAnimating()

        })

    }
    
}
