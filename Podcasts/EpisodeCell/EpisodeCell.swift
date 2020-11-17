//
//  EpisodeCell.swift
//  Podcasts
//
//  Created by Abdalah Omar on 11/4/20.
//  Copyright © 2020 Abdallah. All rights reserved.
//

import UIKit
import SDWebImage

class EpisodeCell: UITableViewCell {
    
    @IBOutlet weak var episodeImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLable: UILabel!
    
    @IBOutlet weak var progressLabel: UILabel!
    var episode :Episode!{
        didSet{
            dateLabel.text = episode.pubDate.convertDate()
            titleLabel.text          = episode.title
            
            descriptionLable.text    = episode.description
            guard let url = URL(string: episode.imageURL?.toSecureHTTPS() ??  "") else{return}
            episodeImage.sd_setImage(with: url, completed: nil)
        }
    }
}

