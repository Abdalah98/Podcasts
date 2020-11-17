//
//  PodcastCell.swift
//  Podcasts
//
//  Created by Abdalah Omar on 11/4/20.
//  Copyright © 2020 Abdallah. All rights reserved.
//

import UIKit
import SDWebImage
class PodcastCell: UITableViewCell {
    
    @IBOutlet weak var podcastImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var episcodeCountLabel: UILabel!
    
    
    var podcast :Results! {
        didSet{
           // print("feed ,",podcast.feedUrl)
            trackNameLabel.text       = podcast.trackName
            artistNameLabel.text      = podcast.artistName
            episcodeCountLabel.text   = "\(podcast.trackCount ) Episodes"
        //    print("imagr",podcast.artworkUrl100 ?? "")
       //     print("imagr",podcast.feedUrl ?? "")

            guard let url = URL(string: podcast.artworkUrl100 ?? "" )else{return}
//            let datatask =  URLSession.shared.dataTask(with: url) { (data, rsponse, error) in
//                if let err = error {return}
//            guard let res = rsponse else{return}
//
//            guard let data = data else{return}
//            print(data)
//            let image = UIImage(data: data)
//                DispatchQueue.main.async {
//                                    self.podcastImageView.image = image
//
//                }
//            }
//            datatask.resume()
        podcastImageView.sd_setImage(with: url, completed: nil)
        }
    }
}
