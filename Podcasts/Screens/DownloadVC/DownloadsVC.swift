//
//  DownloadsVC.swift
//  Podcasts
//
//  Created by Abdalah Omar on 11/2/20.
//  Copyright © 2020 Abdallah. All rights reserved.
//

import UIKit

class DownloadsVC: UITableViewController {
    
    var episode = UserDefaults.standard.downlaodEpisodes()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        configureTableView()
        setupObservers()
    }
    fileprivate func setupObservers(){
        let name                = NSNotification.Name(Constant.downloadProgress)
        let downloadComplete    = NSNotification.Name(Constant.downloadComplete)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownlaodProgress), name: name, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownlaodComplete), name: downloadComplete, object: nil)

    }

    @objc func handleDownlaodProgress(notification:Notification){
        guard let userInfo  =  notification.userInfo as? [String:Any] else{return}
        guard let progress  =  userInfo["progress"] as? Double else{return}
        guard let title     =  userInfo["title"] as?String else{return}

        guard let index =  self.episode.firstIndex(where:{$0.title == title}) else{return}
        guard let cell  = tableView.cellForRow(at: IndexPath(row:index,section: 0)) as? EpisodeCell else{return}
        cell.progressLabel.text = "\(Int(progress * 100 ))%"
        cell.progressLabel.isHidden = false
        if progress == 1 {
            cell.progressLabel.isHidden = true

        }

    }
    
    @objc func handleDownlaodComplete(notification:Notification){
        guard let episodeDownlaodComplete  =  notification.object as? NetworkManger.EpisodeDownlaodCompleteTuple else{return}
        guard let index =  self.episode.firstIndex(where:{$0.title == episodeDownlaodComplete.episodeTitle  }) else{return}

        self.episode[index].fileUrl = episodeDownlaodComplete.fileUrl
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        episode =  UserDefaults.standard.downlaodEpisodes()
        tableView.reloadData()
        
        UIApplication.mainTabaBarController()?.viewControllers?[2].tabBarItem.badgeValue = nil
        
        
    }
    
    
    fileprivate func configureTableView(){
        tableView.tableFooterView = UIView()
        let nib = UINib(nibName: Constant.episodeCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Constant.episodeDatacell)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label                  = UILabel()
        label.text                 = "You have not downloaded any podcasts."
        label.numberOfLines        = 2
        label.textColor            = .systemPurple
        label.textAlignment        = .center
        label.font                 = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }

   override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return episode.count == 0 ? 250 : 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episode.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constant.episodeDatacell, for: indexPath)as! EpisodeCell
        let episodes = episode[indexPath.row]
        cell.episode = episodes
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 134
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else{return}
        let episodes = self.episode[indexPath.row]

        let alretController = UIAlertController(title: "Do you Need Remove \(episodes.title ) Channel?", message: nil, preferredStyle: .actionSheet)
               alretController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
                //delet from tableview
                self.episode.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .left)
                //delet from userdefult
                UserDefaults.standard.deleteEpisode(episode: episodes)
                
                //delet from fileManger
                guard let fileURL = URL(string: episodes.fileUrl ?? "" ) else {return}
                let fileName = fileURL.lastPathComponent
                self.delete(fileName: fileName)
                self.tableView.reloadData()
               }))

               alretController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
               present(alretController, animated: true)
     
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episodes = episode[indexPath.row]
        if episodes.fileUrl != nil {
            UIApplication.mainTabaBarController()?.maximizedPlayerDetails(episode: episodes, playListEpisode: episode)
            
        }
        else{
            let alertController = UIAlertController(title: "File URL not found", message: "cannot find local file , play using stream url instead", preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                UIApplication.mainTabaBarController()?.maximizedPlayerDetails(episode: episodes, playListEpisode: self.episode)
                
            }))
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alertController,animated:  true)
        }
    }
  func delete(fileName : String)->Bool{
    _ = FileManager.default
      let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
      let filePath = docDir.appendingPathComponent(fileName)
      do {
          try FileManager.default.removeItem(at: filePath)
          print("File deleted")
          return true
      }
      catch {
          print("Error")
      }
      return false
  }
  
}
