//
//  Episode.swift
//  Podcasts
//
//  Created by Abdalah Omar on 11/4/20.
//  Copyright © 2020 Abdallah. All rights reserved.
//

import Foundation
import FeedKit

struct Episode : Codable {
    let title            :String
    let pubDate          :Date
    let description      :String
    var imageURL         :String?
    let author           :String
    let streamUrl        :String
    var fileUrl         :String?
    init(feedItem:RSSFeedItem) {
        self.streamUrl    = feedItem.enclosure?.attributes?.url ?? "" 
        self.title        = feedItem.title ?? ""
        self.pubDate      = feedItem.pubDate ?? Date()
        self.description  = feedItem.description ?? ""
        self.author       = feedItem.iTunes?.iTunesAuthor ?? ""
        self.imageURL     = feedItem.iTunes?.iTunesImage?.attributes?.href
        
    }
}
