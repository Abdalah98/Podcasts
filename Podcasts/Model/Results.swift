//
//  Podcast.swift
//  Podcasts
//
//  Created by Abdalah Omar on 11/3/20.
//  Copyright © 2020 Abdallah. All rights reserved.
//

import Foundation
import UIKit
class Results: NSObject, NSCoding , Codable{
    
       var trackName         :String?
       var artistName        :String?
       var artworkUrl100     :String?
       var trackCount        :Int
       var feedUrl           :String?
       
       init(title: String, author: String, published: String,trackCount:Int,feedUrl:String) {
           self.trackName       = title
           self.artistName      = author
           self.artworkUrl100   = published
           self.trackCount      = trackCount
           self.feedUrl         = feedUrl
       }
       
    
    func  encode(with coder: NSCoder) {
        
        coder.encode(trackName ?? "" ,forKey: "trackName")
        coder.encode(artistName ?? "" ,forKey: "artistName")
        coder.encode(artworkUrl100 ?? "" ,forKey: "artworkUrl100")
        coder.encode(trackCount ,forKey: "trackCount")
        coder.encode(feedUrl ?? "" ,forKey: "feedUrl")
    }
    
    required convenience init?(coder: NSCoder) {

        let tarck               = coder.decodeObject(forKey: "trackName") as? String ?? ""
        let artist              = coder.decodeObject(forKey: "artistName") as? String ?? ""
        let image               = coder.decodeObject(forKey: "artworkUrl100") as? String ?? ""
        let count               = coder.decodeObject(forKey: "trackCount") as? Int ?? 0
        let url                 = coder.decodeObject(forKey: "feedUrl") as? String ?? ""
        self.init(title: tarck, author: artist, published: image,trackCount:count,feedUrl:url)
    }
   

    
}
