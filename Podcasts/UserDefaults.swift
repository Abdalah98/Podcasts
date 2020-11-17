//
//  UserDefaults.swift
//  Podcasts
//
//  Created by Abdalah Omar on 11/10/20.
//  Copyright © 2020 Abdallah. All rights reserved.
//

import UIKit
import Foundation
extension UserDefaults{
    func deleteEpisode(episode: Episode) {
       let savedEpisodes = downlaodEpisodes()
       let filteredEpisodes = savedEpisodes.filter { (e) -> Bool in
         // TODO: use episode.collectionId to be safer with deletes
         return e.title != episode.title
       }
       
       do {
         let data = try JSONEncoder().encode(filteredEpisodes)
        UserDefaults.standard.set(data, forKey: Constant.downloadEpisodeKey)
       } catch let encodeErr {
         print("Failed to encode episode:", encodeErr)
       }
     }
    func savedPodcasts() ->[Results]{
        
    guard let savedPodcastData = UserDefaults.standard.data(forKey: Constant.favoritedPodcastKey) else{return []}
        guard let savePodcast = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPodcastData) as? [Results] else {return[]}
        return savePodcast
      }
    // un used
    func deletPosdcast(podcast:Results){
        
        let podcasts = savedPodcasts()
        let filteredPodcasts = podcasts.filter { (p) -> Bool in
            return p.trackName != podcast.trackName && p.artistName != podcast.artistName
        }
        let data = try? NSKeyedArchiver.archivedData(withRootObject: filteredPodcasts, requiringSecureCoding: false)
        UserDefaults.standard.set(data, forKey: Constant.favoritedPodcastKey)
        
    }
    
    func downlaodEpisode(episode:Episode){
        do{
                // why do that so to store more episode in array and git all
            var episodes = downlaodEpisodes()
            episodes.append(episode)
            let data = try JSONEncoder().encode(episodes)
            //svae data
            UserDefaults.standard.set(data, forKey: Constant.downloadEpisodeKey)

        }catch let error {
            print("Failed to encode episode:",error)
        }
    }

    func downlaodEpisodes()->[Episode]{
        //featch data
        guard let episodeData =  UserDefaults.standard.data(forKey: Constant.downloadEpisodeKey) else{return []}
        do{
            //arry to fetch all data 
       let episodeArry = try JSONDecoder().decode([Episode].self, from: episodeData)
            return episodeArry

        }catch let error {
                   print("Failed to encode episode:",error)
               }
        return  []
    }
   
}
