//
//  RSSFeed.swift
//  Podcasts
//
//  Created by Abdalah Omar on 11/4/20.
//  Copyright © 2020 Abdallah. All rights reserved.
//

import Foundation
import  FeedKit

extension RSSFeed{
    
    func toEpisode()->[Episode]{
        let imageUrl                 = iTunes?.iTunesImage?.attributes?.href
        var episodes                 = [Episode]()
        items?.forEach({ (feedItem) in
            var episode              = Episode(feedItem: feedItem)
            if episode.imageURL  == nil{
            episode.imageURL         = imageUrl
            }
            episodes.append(episode)
        })
        return episodes
        
    }
}
